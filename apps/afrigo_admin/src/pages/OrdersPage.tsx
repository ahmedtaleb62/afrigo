import { useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { EmptyState } from '../components/ui/EmptyState'
import { supabase } from '../lib/supabase'

interface OrderRow {
  id: string
  order_type: 'ride' | 'food_order' | 'delivery_request'
  client_id: string
  provider_id: string | null
  price: number | null
  status: string
  created_at: string
}

const TYPE_META: Record<OrderRow['order_type'], { emoji: string; label: string }> = {
  ride: { emoji: '🚕', label: 'تكسي' },
  food_order: { emoji: '🍔', label: 'طعام' },
  delivery_request: { emoji: '📦', label: 'توصيل' },
}

const STATUS_META: Record<string, { label: string; status: 'pending' | 'verified' | 'rejected' | 'offline' }> = {
  completed: { label: 'مكتمل', status: 'verified' },
  delivered: { label: 'تم التسليم', status: 'verified' },
  cancelled: { label: 'ملغى', status: 'rejected' },
  cancelled_by_client: { label: 'ملغى', status: 'rejected' },
  cancelled_by_driver: { label: 'ملغى', status: 'rejected' },
  rejected_by_restaurant: { label: 'مرفوض', status: 'rejected' },
  no_driver_found: { label: 'لا يوجد مزود', status: 'rejected' },
  no_livreur_found: { label: 'لا يوجد مزود', status: 'rejected' },
}
function statusMeta(s: string) {
  return STATUS_META[s] ?? { label: 'جارية', status: 'pending' as const }
}

/**
 * Screen 87 — Orders. The list is real: it reads `all_orders_view` (a UNION
 * of rides/food_orders/delivery_requests — see
 * supabase/migrations/20260802090001_all_orders_view.sql), so it is
 * currently empty (no order-flow Edge Functions exist yet to ever populate
 * these tables — see supabase/README.md). Row detail shows the same static
 * demo content as the design; a real detail view needs per-type item data
 * (`food_orders.items`, etc.) that's out of scope for the shared view.
 */
export function OrdersPage() {
  const [search, setSearch] = useState('')
  const [detailId, setDetailId] = useState<string | null>(null)

  const { data: rows, isLoading } = useQuery({
    queryKey: ['all_orders'],
    queryFn: async (): Promise<OrderRow[]> => {
      const { data, error } = await supabase
        .from('all_orders_view')
        .select('id, order_type, client_id, provider_id, price, status, created_at')
        .order('created_at', { ascending: false })
        .limit(100)
      if (error) throw error
      return data
    },
  })

  const peopleIds = useMemo(() => {
    const ids = new Set<string>()
    for (const r of rows ?? []) {
      ids.add(r.client_id)
      if (r.provider_id) ids.add(r.provider_id)
    }
    return [...ids]
  }, [rows])

  const { data: people } = useQuery({
    queryKey: ['order-people', peopleIds],
    enabled: peopleIds.length > 0,
    queryFn: async () => {
      const { data, error } = await supabase.from('profiles').select('id, full_name').in('id', peopleIds)
      if (error) throw error
      return new Map(data.map((p) => [p.id, p.full_name]))
    },
  })

  const filtered = (rows ?? []).filter((r) => {
    if (!search) return true
    const name = people?.get(r.client_id) ?? ''
    return r.id.includes(search) || name.includes(search)
  })

  const detail = filtered.find((r) => r.id === detailId)

  if (detail) {
    const meta = TYPE_META[detail.order_type]
    return (
      <div>
        <button onClick={() => setDetailId(null)} className="mb-3.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">
          ‹ رجوع لقائمة الطلبات
        </button>
        <div className="grid grid-cols-[1.3fr_1fr] gap-4">
          <Card>
            <div className="mb-3.5 text-base font-extrabold">
              طلب #{detail.id.slice(0, 8)} — {meta.label}
            </div>
            <div className="mb-4 h-30 rounded-[10px] bg-gradient-to-br from-green-100 to-neutral-200" />
            <div className="mb-2 text-xs font-bold text-neutral-500 dark:text-neutral-400">السعر الإجمالي</div>
            <div className="text-lg font-extrabold text-green-700">{detail.price ?? 0} أوقية</div>
          </Card>
          <Card>
            <div className="mb-2.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">الحالة الحالية</div>
            <Badge status={statusMeta(detail.status).status}>{statusMeta(detail.status).label}</Badge>
          </Card>
        </div>
      </div>
    )
  }

  return (
    <div>
      <div className="mb-4 flex gap-2">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="بحث برقم الطلب أو الزبون..."
          className="flex-1 rounded-[10px] border border-neutral-200 bg-white px-3 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-800"
        />
      </div>
      <Card className="overflow-hidden p-0">
        {isLoading ? (
          <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
        ) : filtered.length === 0 ? (
          <EmptyState title="لا توجد طلبات بعد" message="ستظهر طلبات التكسي والطعام والتوصيل هنا فور ورودها" />
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                {['رقم الطلب', 'النوع', 'الزبون', 'مزود الخدمة', 'السعر', 'الحالة'].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => {
                const meta = TYPE_META[r.order_type]
                const st = statusMeta(r.status)
                return (
                  <tr key={r.id} onClick={() => setDetailId(r.id)} className="cursor-pointer">
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs font-bold dark:border-neutral-700">#{r.id.slice(0, 8)}</td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs font-semibold dark:border-neutral-700">
                      {meta.emoji} {meta.label}
                    </td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                      {people?.get(r.client_id) ?? '—'}
                    </td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                      {r.provider_id ? (people?.get(r.provider_id) ?? '—') : '—'}
                    </td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs font-bold dark:border-neutral-700">{r.price ?? 0} أوقية</td>
                    <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                      <Badge status={st.status}>{st.label}</Badge>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  )
}
