import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { Card } from '../components/ui/Card'
import { useToast } from '../components/ui/Toast'
import { supabase } from '../lib/supabase'

type ServiceType = 'taxi' | 'food' | 'delivery'

interface Row {
  service_type: ServiceType
  percentage: number
  base_fare: number
  price_per_km: number
  price_per_min: number
}

const SERVICES: { type: ServiceType; emoji: string; label: string; feeLabel: string; showPerMin: boolean }[] = [
  { type: 'taxi', emoji: '🚕', label: 'تكسي', feeLabel: 'الأجرة الأساسية (أوقية)', showPerMin: true },
  { type: 'food', emoji: '🍔', label: 'طعام', feeLabel: 'رسوم توصيل أساسية (أوقية)', showPerMin: false },
  { type: 'delivery', emoji: '📦', label: 'توصيل', feeLabel: 'الأجرة الأساسية (أوقية)', showPerMin: true },
]

/**
 * Commission & pricing settings — real read/write. Unlike `vehicles.status`
 * or `wallets.balance`, `commission_settings`/`pricing_settings` have no
 * service-role-only trigger guard: RLS alone (`is_admin()`) allows the
 * signed-in admin's own session to update these directly.
 */
export function CommissionSettingsPage() {
  const navigate = useNavigate()
  const { show } = useToast()
  const [values, setValues] = useState<Record<ServiceType, Row> | null>(null)
  const [saving, setSaving] = useState(false)

  const { data } = useQuery({
    queryKey: ['pricing-and-commission'],
    queryFn: async () => {
      const [commission, pricing] = await Promise.all([
        supabase.from('commission_settings').select('service_type, percentage'),
        supabase.from('pricing_settings').select('service_type, base_fare, price_per_km, price_per_min'),
      ])
      if (commission.error) throw commission.error
      if (pricing.error) throw pricing.error
      const merged = {} as Record<ServiceType, Row>
      for (const c of commission.data) {
        const p = pricing.data.find((x) => x.service_type === c.service_type)
        merged[c.service_type as ServiceType] = {
          service_type: c.service_type as ServiceType,
          percentage: c.percentage,
          base_fare: p?.base_fare ?? 0,
          price_per_km: p?.price_per_km ?? 0,
          price_per_min: p?.price_per_min ?? 0,
        }
      }
      return merged
    },
  })

  useEffect(() => {
    if (data) setValues(data)
  }, [data])

  function update(type: ServiceType, field: keyof Row, value: string) {
    setValues((prev) => (prev ? { ...prev, [type]: { ...prev[type], [field]: Number(value) || 0 } } : prev))
  }

  async function save() {
    if (!values) return
    setSaving(true)
    try {
      await Promise.all(
        SERVICES.map(async ({ type }) => {
          const v = values[type]
          await supabase.from('commission_settings').update({ percentage: v.percentage }).eq('service_type', type)
          await supabase
            .from('pricing_settings')
            .update({ base_fare: v.base_fare, price_per_km: v.price_per_km, price_per_min: v.price_per_min })
            .eq('service_type', type)
        }),
      )
      show('تم حفظ إعدادات العمولة والتسعير بنجاح')
    } catch {
      show('تعذّر حفظ الإعدادات', { isError: true })
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <button onClick={() => navigate('/wallets')} className="mb-3.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">
        ‹ رجوع للمحافظ
      </button>
      {!values ? (
        <p className="text-sm text-neutral-500">جارٍ التحميل...</p>
      ) : (
        <>
          <div className="grid grid-cols-3 gap-3.5">
            {SERVICES.map((svc) => {
              const v = values[svc.type]
              return (
                <Card key={svc.type}>
                  <div className="mb-3.5 text-sm font-extrabold">
                    {svc.emoji} {svc.label}
                  </div>
                  <NumField label="نسبة العمولة (%)" value={v.percentage} onChange={(val) => update(svc.type, 'percentage', val)} />
                  <NumField label={svc.feeLabel} value={v.base_fare} onChange={(val) => update(svc.type, 'base_fare', val)} />
                  <NumField label="السعر لكل كم" value={v.price_per_km} onChange={(val) => update(svc.type, 'price_per_km', val)} last={!svc.showPerMin} />
                  {svc.showPerMin && <NumField label="السعر لكل دقيقة" value={v.price_per_min} onChange={(val) => update(svc.type, 'price_per_min', val)} last />}
                </Card>
              )
            })}
          </div>
          <button
            onClick={save}
            disabled={saving}
            className="mt-4 rounded-[10px] bg-green-500 px-6 py-3 text-[13px] font-bold text-white disabled:opacity-60"
          >
            {saving ? '...' : 'حفظ الإعدادات'}
          </button>
        </>
      )}
    </div>
  )
}

function NumField({ label, value, onChange, last = false }: { label: string; value: number; onChange: (v: string) => void; last?: boolean }) {
  return (
    <div className={last ? '' : 'mb-2.5'}>
      <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">{label}</label>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        inputMode="decimal"
        className="w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
      />
    </div>
  )
}
