import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card, TabPill } from '../components/ui/Card'
import { invokeFunction } from '../lib/functions'

type Period = 'day' | 'week' | 'month' | 'year'

interface DashboardStats {
  period: Period
  stats: {
    revenue_today: number
    revenue_yesterday: number
    orders_today: number
    orders_yesterday: number
    active_users_today: number
    active_users_yesterday: number
    active_providers_now: number
    avg_order_value_today: number
  }
  orders_by_service: Record<string, number>
  orders_by_hour: Record<string, number>
  revenue_series: { bucket: string; service_type: string; revenue: number }[]
  leaderboard: {
    drivers: { id: string; name: string; orders: number; rating: number; revenue: number }[]
    restaurants: { id: string; name: string; orders: number; rating: number; revenue: number }[]
    couriers: { id: string; name: string; orders: number; rating: number; revenue: number }[]
  }
  growth: { bucket: string; role: string; count: number }[]
}

const SERVICE_COLOR: Record<string, string> = { taxi: '#2AA35C', food: '#F5C518', delivery: '#1D7A9C' }
const SERVICE_LABEL: Record<string, string> = { taxi: 'تكسي', food: 'طعام', delivery: 'توصيل' }
const PROVIDER_ROLES = ['taxi_driver', 'restaurant_owner', 'livreur']

function pctDelta(today: number, yesterday: number): { label: string; up: boolean } | null {
  if (yesterday === 0) return null
  const pct = ((today - yesterday) / yesterday) * 100
  return { label: `${pct >= 0 ? '▲' : '▼'} ${Math.abs(pct).toFixed(1)}%`, up: pct >= 0 }
}

function fmt(n: number): string {
  return n.toLocaleString('en-US', { maximumFractionDigits: 0 })
}

/** Maps a sorted list of numeric values onto an SVG polyline `points` string. */
function toPolyline(values: number[], maxVal: number, width: number, height: number): string {
  if (values.length === 0) return ''
  if (values.length === 1) return `0,${height} ${width},${height - (maxVal > 0 ? (values[0] / maxVal) * height : 0)}`
  return values
    .map((v, i) => {
      const x = (i / (values.length - 1)) * width
      const y = height - (maxVal > 0 ? (v / maxVal) * height : 0)
      return `${x.toFixed(1)},${y.toFixed(1)}`
    })
    .join(' ')
}

/** Group `revenue_series` into one ordered value-array per service type, sharing the same bucket axis. */
function buildRevenueSeries(rows: DashboardStats['revenue_series']) {
  const buckets = [...new Set(rows.map((r) => r.bucket))].sort()
  const byService: Record<string, number[]> = { taxi: [], food: [], delivery: [] }
  for (const service of Object.keys(byService)) {
    byService[service] = buckets.map((b) => rows.find((r) => r.bucket === b && r.service_type === service)?.revenue ?? 0)
  }
  const maxVal = Math.max(1, ...Object.values(byService).flat())
  return { buckets, byService, maxVal }
}

/** Group `growth` into "new users" (client) vs "new providers" (taxi_driver+restaurant_owner+livreur) per bucket. */
function buildGrowthSeries(rows: DashboardStats['growth']) {
  const buckets = [...new Set(rows.map((r) => r.bucket))].sort()
  const users = buckets.map((b) => rows.find((r) => r.bucket === b && r.role === 'client')?.count ?? 0)
  const providers = buckets.map((b) => buckets.length && rows.filter((r) => r.bucket === b && PROVIDER_ROLES.includes(r.role)).reduce((s, r) => s + r.count, 0))
  const maxVal = Math.max(1, ...users, ...providers)
  return { users, providers, maxVal }
}

/**
 * Screen 84 — Overview. Real aggregation via the `admin-dashboard-stats`
 * RPC-backed Edge Function (one SQL round trip server-side — see
 * supabase/functions/admin-dashboard-stats and the
 * `admin_dashboard_stats` Postgres function it calls). The geographic
 * order-density card stays a static placeholder — it needs a spatial
 * binning strategy sized to real order volume, which doesn't exist on a
 * fresh install; see supabase/README.md.
 */
export function OverviewPage() {
  const [period, setPeriod] = useState<Period>('week')
  const [lbTab, setLbTab] = useState<'drivers' | 'restaurants' | 'couriers'>('drivers')

  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard-stats', period],
    queryFn: () => invokeFunction<DashboardStats>('admin-dashboard-stats', { period }),
  })

  if (isLoading || !data) {
    return <div className="p-8 text-center text-sm text-neutral-500">{isError ? 'تعذّر تحميل الإحصائيات' : 'جارٍ التحميل...'}</div>
  }

  const revenueDelta = pctDelta(data.stats.revenue_today, data.stats.revenue_yesterday)
  const ordersDelta = pctDelta(data.stats.orders_today, data.stats.orders_yesterday)
  const usersDelta = pctDelta(data.stats.active_users_today, data.stats.active_users_yesterday)

  const stats: { label: string; value: string; delta: string | null; up: boolean }[] = [
    { label: 'إيرادات المنصة (اليوم)', value: `${fmt(data.stats.revenue_today)} أوقية`, delta: revenueDelta?.label ?? null, up: revenueDelta?.up ?? true },
    { label: 'إجمالي الطلبات', value: fmt(data.stats.orders_today), delta: ordersDelta?.label ?? null, up: ordersDelta?.up ?? true },
    { label: 'المستخدمون النشطون', value: fmt(data.stats.active_users_today), delta: usersDelta?.label ?? null, up: usersDelta?.up ?? true },
    { label: 'مزودو الخدمة النشطون الآن', value: fmt(data.stats.active_providers_now), delta: null, up: true },
    { label: 'متوسط قيمة الطلب', value: `${fmt(data.stats.avg_order_value_today)} أوقية`, delta: null, up: true },
  ]

  const serviceTotal = Object.values(data.orders_by_service).reduce((s, n) => s + n, 0)
  const servicePcts = Object.entries(data.orders_by_service).map(([service, count]) => ({
    service,
    pct: serviceTotal > 0 ? (count / serviceTotal) * 100 : 0,
  }))
  let cumulative = 0
  const pieSegments = servicePcts.map(({ service, pct }) => {
    const seg = { service, pct, offset: 25 - cumulative }
    cumulative += pct
    return seg
  })

  const hourCounts = Array.from({ length: 24 }, (_, h) => data.orders_by_hour[String(h)] ?? 0)
  const maxHour = Math.max(1, ...hourCounts)
  const peakHour = hourCounts.indexOf(Math.max(...hourCounts))
  const peakLabel = maxHour > 1 ? `ذروة الطلب: ${peakHour}:00 - ${(peakHour + 1) % 24}:00` : 'لا توجد بيانات كافية بعد'

  const revenueSeries = buildRevenueSeries(data.revenue_series)
  const growthSeries = buildGrowthSeries(data.growth)

  const lbRows = data.leaderboard[lbTab]

  return (
    <div className="flex flex-col gap-3.5">
      <div className="grid grid-cols-5 gap-3.5">
        {stats.map((s) => (
          <Card key={s.label}>
            <div className="mb-1.5 text-[11px] text-neutral-500 dark:text-neutral-400">{s.label}</div>
            <div className="text-xl font-extrabold">{s.value}</div>
            {s.delta && <div className={`mt-1 text-[11px] font-bold ${s.up ? 'text-green-700' : 'text-error'}`}>{s.delta}</div>}
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-[2fr_1fr] gap-3.5">
        <Card>
          <div className="mb-3.5 flex items-center justify-between">
            <div className="text-sm font-extrabold">إيرادات المنصة عبر الزمن</div>
            <div className="flex gap-1.5">
              {(['day', 'week', 'month', 'year'] as const).map((p) => (
                <TabPill key={p} active={period === p} onClick={() => setPeriod(p)}>
                  {{ day: 'يوم', week: 'أسبوع', month: 'شهر', year: 'سنة' }[p]}
                </TabPill>
              ))}
            </div>
          </div>
          {revenueSeries.buckets.length === 0 ? (
            <div className="flex h-50 items-center justify-center text-xs text-neutral-500 dark:text-neutral-400">لا توجد بيانات إيرادات لهذه الفترة</div>
          ) : (
            <svg width="100%" height="200" viewBox="0 0 560 200">
              {Object.entries(revenueSeries.byService).map(([service, values]) => (
                <polyline key={service} points={toPolyline(values, revenueSeries.maxVal, 560, 200)} fill="none" stroke={SERVICE_COLOR[service]} strokeWidth="3" />
              ))}
            </svg>
          )}
          <div className="mt-2 flex gap-4">
            <Legend color="#2AA35C" label="تكسي" />
            <Legend color="#F5C518" label="طعام" />
            <Legend color="#1D7A9C" label="توصيل" />
          </div>
        </Card>

        <Card>
          <div className="mb-3.5 text-sm font-extrabold">الطلبات حسب الخدمة</div>
          {serviceTotal === 0 ? (
            <div className="flex h-45 items-center justify-center text-xs text-neutral-500 dark:text-neutral-400">لا توجد طلبات بعد</div>
          ) : (
            <svg width="180" height="180" viewBox="0 0 42 42" className="mx-auto block">
              {pieSegments.map(({ service, pct, offset }) => (
                <circle key={service} cx="21" cy="21" r="15.9" fill="transparent" stroke={SERVICE_COLOR[service]} strokeWidth="6" strokeDasharray={`${pct} ${100 - pct}`} strokeDashoffset={offset} />
              ))}
            </svg>
          )}
          <div className="mt-3.5 flex flex-col gap-2">
            {servicePcts.map(({ service, pct }) => (
              <PieRow key={service} color={SERVICE_COLOR[service]} label={SERVICE_LABEL[service] ?? service} pct={`${pct.toFixed(0)}%`} />
            ))}
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-2 gap-3.5">
        <Card>
          <div className="mb-3.5 text-sm font-extrabold">الطلبات حسب ساعة الذروة</div>
          <svg width="100%" height="140" viewBox="0 0 816 140">
            {hourCounts.map((count, h) => {
              const height = (count / maxHour) * 130
              return <rect key={h} x={h * 34} y={140 - height} width="24" height={height} fill={h === peakHour ? '#176F3D' : '#82D6A0'} />
            })}
          </svg>
          <div className="mt-1.5 text-[11px] text-neutral-500 dark:text-neutral-400">{peakLabel}</div>
        </Card>
        <Card>
          <div className="mb-2.5 text-sm font-extrabold">الكثافة الجغرافية للطلبات</div>
          <div
            className="relative h-35 overflow-hidden rounded-[10px] bg-neutral-200"
            style={{
              backgroundImage:
                'radial-gradient(circle at 30% 40%, rgba(220,38,38,.35), transparent 35%), radial-gradient(circle at 65% 55%, rgba(245,197,24,.35), transparent 30%), radial-gradient(circle at 50% 75%, rgba(42,163,92,.3), transparent 30%)',
            }}
          />
          <div className="mt-1.5 text-[11px] text-neutral-500 dark:text-neutral-400">قريبًا — يحتاج حجم طلبات حقيقي لعرض خريطة كثافة دقيقة</div>
        </Card>
      </div>

      <Card>
        <div className="mb-3 flex items-center justify-between">
          <div className="text-sm font-extrabold">الأفضل أداءً (Leaderboard)</div>
          <div className="flex gap-1.5">
            <TabPill active={lbTab === 'drivers'} onClick={() => setLbTab('drivers')}>سائقون</TabPill>
            <TabPill active={lbTab === 'restaurants'} onClick={() => setLbTab('restaurants')}>مطاعم</TabPill>
            <TabPill active={lbTab === 'couriers'} onClick={() => setLbTab('couriers')}>مندوبون</TabPill>
          </div>
        </div>
        {lbRows.length === 0 ? (
          <div className="p-6 text-center text-xs text-neutral-500 dark:text-neutral-400">لا توجد بيانات كافية بعد</div>
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr className="text-right">
                {['#', 'الاسم', 'الطلبات', 'التقييم', 'الإيرادات'].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-1.5 py-2 text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {lbRows.map((row, i) => (
                <tr key={row.id}>
                  <td className="px-1.5 py-2.5 text-xs font-bold">{i + 1}</td>
                  <td className="px-1.5 py-2.5 text-xs font-semibold">{row.name}</td>
                  <td className="px-1.5 py-2.5 text-xs font-semibold">{row.orders}</td>
                  <td className="px-1.5 py-2.5 text-xs font-semibold">⭐ {row.rating}</td>
                  <td className="px-1.5 py-2.5 text-xs font-bold text-green-700">{fmt(row.revenue)} أوقية</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>

      <Card>
        <div className="mb-3.5 text-sm font-extrabold">نمو المستخدمين ومزودي الخدمة</div>
        {growthSeries.users.length === 0 ? (
          <div className="flex h-35 items-center justify-center text-xs text-neutral-500 dark:text-neutral-400">لا توجد بيانات نمو لهذه الفترة</div>
        ) : (
          <svg width="100%" height="140" viewBox="0 0 560 140">
            <polyline points={toPolyline(growthSeries.users, growthSeries.maxVal, 560, 140)} fill="none" stroke="#2AA35C" strokeWidth="3" />
            <polyline points={toPolyline(growthSeries.providers, growthSeries.maxVal, 560, 140)} fill="none" stroke="#F5C518" strokeWidth="3" />
          </svg>
        )}
        <div className="mt-2 flex gap-4">
          <Legend color="#2AA35C" label="مستخدمون جدد" />
          <Legend color="#F5C518" label="مزودو خدمة جدد" />
        </div>
      </Card>
    </div>
  )
}

function Legend({ color, label }: { color: string; label: string }) {
  return (
    <div className="flex items-center gap-1.5">
      <span className="h-2.5 w-2.5 rounded-full" style={{ background: color }} />
      <span className="text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">{label}</span>
    </div>
  )
}

function PieRow({ color, label, pct }: { color: string; label: string; pct: string }) {
  return (
    <div className="flex justify-between text-xs font-semibold">
      <span>
        <span style={{ color }}>●</span> {label}
      </span>
      <span className="font-bold">{pct}</span>
    </div>
  )
}
