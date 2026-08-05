import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { Card, TabPill } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { EmptyState } from '../components/ui/EmptyState'
import { useToast } from '../components/ui/Toast'
import { supabase } from '../lib/supabase'
import { invokeFunction } from '../lib/functions'

type VerifTab = 'taxi' | 'delivery' | 'restaurants'

interface VerifRow {
  id: string
  name: string
  status: string
  rejection_reason: string | null
  created_at: string
  plate_number?: string
  address: string
}

const STATUS_MAP: Record<string, { label: string; status: 'pending' | 'verified' | 'rejected' }> = {
  pending: { label: 'قيد المراجعة', status: 'pending' },
  verified: { label: 'موثّق', status: 'verified' },
  rejected: { label: 'مرفوض', status: 'rejected' },
}

/**
 * Screen 85 — Verification. List + detail are real (`vehicles`/`restaurants`,
 * admin sees all rows via RLS). Approve/Reject call the real `review-verification`
 * Edge Function — `status` is guarded so only that service-role function can
 * change it, see supabase/migrations/20260731230003_vehicles.sql.
 */
export function VerificationPage() {
  const [tab, setTab] = useState<VerifTab>('taxi')
  const [detail, setDetail] = useState<VerifRow | null>(null)
  const [rejectOpen, setRejectOpen] = useState(false)
  const [rejectReason, setRejectReason] = useState('')
  const [deciding, setDeciding] = useState(false)
  const { show } = useToast()
  const queryClient = useQueryClient()

  const { data: rows, isLoading } = useQuery({
    queryKey: ['verification', tab],
    queryFn: async (): Promise<VerifRow[]> => {
      if (tab === 'restaurants') {
        const { data, error } = await supabase
          .from('restaurants')
          .select('id, name, status, rejection_reason, created_at, address')
          .order('created_at', { ascending: false })
        if (error) throw error
        return data
      }
      const { data, error } = await supabase
        .from('vehicles')
        .select('id, vehicle_name, status, rejection_reason, created_at, plate_number, address')
        .eq('service_type', tab)
        .order('created_at', { ascending: false })
      if (error) throw error
      return data.map((v) => ({ ...v, name: v.vehicle_name }))
    },
  })

  async function decide(action: 'approve' | 'reject') {
    if (!detail) return
    if (action === 'reject' && !rejectReason.trim()) {
      show('سبب الرفض إجباري', { isError: true })
      return
    }
    setDeciding(true)
    try {
      await invokeFunction('review-verification', {
        entity: tab === 'restaurants' ? 'restaurant' : 'vehicle',
        id: detail.id,
        decision: action,
        rejection_reason: action === 'reject' ? rejectReason.trim() : undefined,
      })
      show(action === 'approve' ? 'تم التوثيق بنجاح' : 'تم رفض الطلب')
      queryClient.invalidateQueries({ queryKey: ['verification', tab] })
      setDetail(null)
      setRejectOpen(false)
      setRejectReason('')
    } catch (err) {
      show(err instanceof Error ? err.message : 'حدث خطأ، حاول مجددًا', { isError: true })
    } finally {
      setDeciding(false)
    }
  }

  if (detail) {
    const st = STATUS_MAP[detail.status] ?? STATUS_MAP.pending
    return (
      <div>
        <button onClick={() => setDetail(null)} className="mb-3.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">
          ‹ رجوع لقائمة التوثيق
        </button>
        <div className="grid grid-cols-[1.4fr_1fr] gap-4">
          <Card>
            <div className="mb-3.5 text-base font-extrabold">{detail.name}</div>
            <div className="mb-4 grid grid-cols-2 gap-3">
              <Field label="النوع" value={tab === 'restaurants' ? 'مطعم' : tab === 'taxi' ? 'مركبة تكسي' : 'مركبة توصيل'} />
              <Field label="تاريخ التقديم" value={new Date(detail.created_at).toLocaleDateString('ar')} />
              <Field label="رقم اللوحة" value={detail.plate_number ?? '—'} />
              <Field label="العنوان" value={detail.address} />
            </div>
            <div className="mb-2 text-xs font-bold text-neutral-500 dark:text-neutral-400">المستندات المرفوعة</div>
            <div className="mb-5 grid grid-cols-2 gap-2.5">
              <div className="flex h-30 items-center justify-center rounded-[10px] bg-neutral-100 text-2xl dark:bg-neutral-700">🪪</div>
              <div className="flex h-30 items-center justify-center rounded-[10px] bg-neutral-100 text-2xl dark:bg-neutral-700">📄</div>
            </div>
            {rejectOpen ? (
              <>
                <textarea
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                  placeholder="سبب الرفض (إجباري)"
                  className="mb-3 min-h-17.5 w-full rounded-[10px] border border-error bg-error-surface p-3 text-[13px]"
                />
                <button disabled={deciding} onClick={() => decide('reject')} className="w-full rounded-[10px] bg-error py-3 text-[13px] font-bold text-white disabled:opacity-60">
                  تأكيد الرفض وإرسال السبب
                </button>
              </>
            ) : (
              <div className="flex gap-2.5">
                <button disabled={deciding} onClick={() => setRejectOpen(true)} className="flex-1 rounded-[10px] bg-error-surface py-3 text-[13px] font-bold text-error disabled:opacity-60">
                  رفض
                </button>
                <button disabled={deciding} onClick={() => decide('approve')} className="flex-1 rounded-[10px] bg-green-500 py-3 text-[13px] font-bold text-white disabled:opacity-60">
                  موافقة
                </button>
              </div>
            )}
          </Card>
          <Card>
            <div className="mb-2.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">الحالة الحالية</div>
            <Badge status={st.status}>{st.label}</Badge>
            {detail.rejection_reason && (
              <p className="mt-3 text-xs text-neutral-500 dark:text-neutral-400">سبب آخر رفض: {detail.rejection_reason}</p>
            )}
          </Card>
        </div>
      </div>
    )
  }

  return (
    <div>
      <div className="mb-4 flex gap-2">
        <TabPill active={tab === 'taxi'} onClick={() => setTab('taxi')}>مركبات تكسي</TabPill>
        <TabPill active={tab === 'delivery'} onClick={() => setTab('delivery')}>مركبات توصيل</TabPill>
        <TabPill active={tab === 'restaurants'} onClick={() => setTab('restaurants')}>مطاعم</TabPill>
      </div>
      <Card className="overflow-hidden p-0">
        {isLoading ? (
          <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
        ) : !rows || rows.length === 0 ? (
          <EmptyState title="لا توجد طلبات توثيق" message="لم يقدّم أي أحد طلب توثيق في هذه الفئة بعد" />
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                {['اسم المتقدم', 'تاريخ التقديم', 'الحالة', ''].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => {
                const st = STATUS_MAP[row.status] ?? STATUS_MAP.pending
                return (
                  <tr key={row.id} onClick={() => setDetail(row)} className="cursor-pointer">
                    <td className="border-b border-neutral-200 px-4 py-3 text-[13px] font-semibold dark:border-neutral-700">{row.name}</td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                      {new Date(row.created_at).toLocaleDateString('ar')}
                    </td>
                    <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                      <Badge status={st.status}>{st.label}</Badge>
                    </td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs font-bold text-green-700 dark:border-neutral-700">عرض ›</td>
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

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-[11px] text-neutral-500 dark:text-neutral-400">{label}</div>
      <div className="text-[13px] font-bold">{value}</div>
    </div>
  )
}
