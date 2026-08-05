import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card } from '../components/ui/Card'
import { EmptyState } from '../components/ui/EmptyState'
import { Switch } from '../components/ui/Switch'
import { supabase } from '../lib/supabase'

interface RatingRow {
  id: string
  rating: number
  comment: string | null
  rated_entity_type: string
  rated_entity_id: string
  profiles: { full_name: string } | null
}

const ENTITY_LABEL: Record<string, string> = { driver: 'سائق', restaurant: 'مطعم', livreur: 'مندوب', client: 'عميل' }

/** Screen 90 — Ratings. Real read from `ratings` (admin sees all via RLS).
 * `rated_entity_id` is polymorphic (profiles or restaurants depending on
 * `rated_entity_type`), so the "إلى" column shows the entity type rather
 * than resolving a name across two possible tables. */
export function RatingsPage() {
  const [lowOnly, setLowOnly] = useState(false)

  const { data: rows, isLoading } = useQuery({
    queryKey: ['ratings', lowOnly],
    queryFn: async (): Promise<RatingRow[]> => {
      let query = supabase
        .from('ratings')
        .select('id, rating, comment, rated_entity_type, rated_entity_id, profiles(full_name)')
        .order('created_at', { ascending: false })
        .limit(100)
      if (lowOnly) query = query.lte('rating', 2)
      const { data, error } = await query
      if (error) throw error
      return data as unknown as RatingRow[]
    },
  })

  return (
    <div>
      <div className="mb-4 flex items-center gap-2.5">
        <div className="flex items-center gap-2 rounded-[10px] border border-neutral-200 bg-white px-3.5 py-2.5 dark:border-neutral-700 dark:bg-neutral-800">
          <Switch
            checked={lowOnly}
            onChange={setLowOnly}
            onLabel="عرض التقييمات المنخفضة فقط (1-2 نجوم)"
            offLabel="عرض التقييمات المنخفضة فقط (1-2 نجوم)"
            className="flex-row-reverse items-center gap-2"
          />
        </div>
      </div>
      <Card className="overflow-hidden p-0">
        {isLoading ? (
          <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
        ) : !rows || rows.length === 0 ? (
          <EmptyState title="لا توجد تقييمات بعد" message="ستظهر تقييمات الرحلات والطلبات هنا" />
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                {['من', 'إلى', 'التقييم', 'تعليق'].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td className="border-b border-neutral-200 px-4 py-3 text-[13px] font-semibold dark:border-neutral-700">{r.profiles?.full_name ?? '—'}</td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {ENTITY_LABEL[r.rated_entity_type] ?? r.rated_entity_type}
                  </td>
                  <td className={`border-b border-neutral-200 px-4 py-3 text-xs font-bold dark:border-neutral-700 ${r.rating <= 2 ? 'text-error' : ''}`}>
                    {'⭐'.repeat(r.rating)}
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">{r.comment ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  )
}
