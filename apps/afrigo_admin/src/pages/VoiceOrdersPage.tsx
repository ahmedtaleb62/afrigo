import { useQuery } from '@tanstack/react-query'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { EmptyState } from '../components/ui/EmptyState'
import { supabase } from '../lib/supabase'

interface VoiceOrderRow {
  id: string
  transcribed_text: string | null
  service_type: string | null
  status: string
  audio_url: string
  created_at: string
  profiles: { full_name: string } | null
}

const STATUS_META: Record<string, { label: string; status: 'verified' | 'rejected' | 'pending' }> = {
  confirmed: { label: 'نجاح', status: 'verified' },
  pending_confirmation: { label: 'بانتظار التأكيد', status: 'pending' },
  processing: { label: 'قيد المعالجة', status: 'pending' },
  failed: { label: 'فشل', status: 'rejected' },
}

const SERVICE_LABEL: Record<string, string> = { ride: '🚕 تكسي', food_order: '🍔 طعام', delivery_request: '📦 توصيل' }

/** Screen 88 — Voice orders. Real read from `voice_orders` (admin sees all
 * via RLS). Playback needs a signed URL against the `voice-recordings`
 * Storage bucket, which isn't created yet — see supabase/README.md. */
export function VoiceOrdersPage() {
  const { data: rows, isLoading } = useQuery({
    queryKey: ['voice_orders'],
    queryFn: async (): Promise<VoiceOrderRow[]> => {
      const { data, error } = await supabase
        .from('voice_orders')
        .select('id, transcribed_text, service_type, status, audio_url, created_at, profiles(full_name)')
        .order('created_at', { ascending: false })
        .limit(100)
      if (error) throw error
      return data as unknown as VoiceOrderRow[]
    },
  })

  return (
    <Card className="overflow-hidden p-0">
      {isLoading ? (
        <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
      ) : !rows || rows.length === 0 ? (
        <EmptyState title="لا توجد طلبات صوتية بعد" message="ستظهر تسجيلات الطلب الصوتي من التطبيق هنا" />
      ) : (
        <table className="w-full border-collapse">
          <thead>
            <tr>
              {['الزبون', 'التاريخ', 'النص المُفرَّغ', 'النوع المستخرج', 'الحالة', 'استماع'].map((h) => (
                <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => {
              const st = STATUS_META[r.status] ?? STATUS_META.processing
              return (
                <tr key={r.id}>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs font-semibold dark:border-neutral-700">{r.profiles?.full_name ?? '—'}</td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {new Date(r.created_at).toLocaleString('ar')}
                  </td>
                  <td className="max-w-55 border-b border-neutral-200 px-4 py-3 text-xs dark:border-neutral-700">
                    {r.transcribed_text ? `"${r.transcribed_text}"` : '—'}
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs font-semibold dark:border-neutral-700">
                    {r.service_type ? (SERVICE_LABEL[r.service_type] ?? r.service_type) : '—'}
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                    <Badge status={st.status}>{st.label}</Badge>
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-400 dark:border-neutral-700">🔇 غير متاح بعد</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      )}
    </Card>
  )
}
