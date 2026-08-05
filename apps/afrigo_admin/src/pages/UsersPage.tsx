import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { Card, TabPill } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { EmptyState } from '../components/ui/EmptyState'
import { useToast } from '../components/ui/Toast'
import { supabase } from '../lib/supabase'
import { invokeFunction } from '../lib/functions'

type UserTab = 'client' | 'taxi_driver' | 'restaurant_owner' | 'livreur'

const TABS: { role: UserTab; label: string }[] = [
  { role: 'client', label: 'عملاء' },
  { role: 'taxi_driver', label: 'سائقون' },
  { role: 'restaurant_owner', label: 'مطاعم' },
  { role: 'livreur', label: 'مندوبون' },
]

interface ProfileRow {
  id: string
  full_name: string
  email: string | null
  is_suspended: boolean
  created_at: string
}

/**
 * Screen 89 — Users. The list is real (`profiles`, admin reads all via
 * RLS). Suspend/activate calls the real `admin-suspend-user` Edge
 * Function — `is_suspended` is guarded so only that service-role function
 * can change it, and every call lands a row in `admin_audit_log` — see
 * supabase/migrations/20260731230002_profiles.sql.
 */
export function UsersPage() {
  const [tab, setTab] = useState<UserTab>('client')
  const [pendingId, setPendingId] = useState<string | null>(null)
  const { show } = useToast()
  const queryClient = useQueryClient()

  const { data: rows, isLoading } = useQuery({
    queryKey: ['users', tab],
    queryFn: async (): Promise<ProfileRow[]> => {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, email, is_suspended, created_at')
        .eq('role', tab)
        .order('created_at', { ascending: false })
      if (error) throw error
      return data
    },
  })

  async function toggleSuspend(user: ProfileRow) {
    setPendingId(user.id)
    try {
      await invokeFunction('admin-suspend-user', { user_id: user.id, suspended: !user.is_suspended })
      show(user.is_suspended ? 'تم تفعيل الحساب' : 'تم تعليق الحساب')
      queryClient.invalidateQueries({ queryKey: ['users', tab] })
    } catch (err) {
      show(err instanceof Error ? err.message : 'حدث خطأ، حاول مجددًا', { isError: true })
    } finally {
      setPendingId(null)
    }
  }

  return (
    <div>
      <div className="mb-4 flex gap-2">
        {TABS.map((t) => (
          <TabPill key={t.role} active={tab === t.role} onClick={() => setTab(t.role)}>
            {t.label}
          </TabPill>
        ))}
      </div>
      <Card className="overflow-hidden p-0">
        {isLoading ? (
          <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
        ) : !rows || rows.length === 0 ? (
          <EmptyState title="لا يوجد مستخدمون بعد" message="سيظهرون هنا فور التسجيل في هذه الفئة" />
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                {['الاسم', 'البريد الإلكتروني', 'تاريخ التسجيل', 'الحالة', ''].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((u) => (
                <tr key={u.id}>
                  <td className="border-b border-neutral-200 px-4 py-3 text-[13px] font-semibold dark:border-neutral-700">{u.full_name}</td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">{u.email ?? '—'}</td>
                  <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {new Date(u.created_at).toLocaleDateString('ar')}
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                    <Badge status={u.is_suspended ? 'rejected' : 'verified'}>{u.is_suspended ? 'موقوف' : 'نشط'}</Badge>
                  </td>
                  <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                    <button disabled={pendingId === u.id} onClick={() => toggleSuspend(u)} className="text-xs font-bold text-error disabled:opacity-60">
                      {u.is_suspended ? 'تفعيل الحساب' : 'تعليق الحساب'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  )
}
