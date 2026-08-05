import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card } from '../components/ui/Card'
import { useToast } from '../components/ui/Toast'
import { supabase } from '../lib/supabase'

interface AdminRow {
  id: string
  full_name: string
}

interface AuditRow {
  id: string
  action: string
  target_table: string
  created_at: string
  profiles: { full_name: string } | null
}

/**
 * Screen 91 — General settings. Admin list + audit log are real reads.
 * `platform_settings` (support phone, terms text) is real read/write — no
 * service-role-only guard on that table, RLS's `is_admin()` is enough.
 * "+ إضافة مشرف" is NOT wired: creating an `auth.users` row needs the
 * Supabase Auth Admin API, which requires the service_role key and must
 * never be called from the browser — that needs its own Edge Function.
 */
export function SettingsPage() {
  const { show } = useToast()
  const [supportPhone, setSupportPhone] = useState('')
  const [terms, setTerms] = useState('')
  const [saving, setSaving] = useState(false)

  const { data: admins } = useQuery({
    queryKey: ['admins'],
    queryFn: async (): Promise<AdminRow[]> => {
      const { data, error } = await supabase.from('profiles').select('id, full_name').eq('role', 'admin')
      if (error) throw error
      return data
    },
  })

  const { data: auditLog } = useQuery({
    queryKey: ['audit-log'],
    queryFn: async (): Promise<AuditRow[]> => {
      const { data, error } = await supabase
        .from('admin_audit_log')
        .select('id, action, target_table, created_at, profiles(full_name)')
        .order('created_at', { ascending: false })
        .limit(20)
      if (error) throw error
      return data as unknown as AuditRow[]
    },
  })

  const { data: settings } = useQuery({
    queryKey: ['platform-settings'],
    queryFn: async () => {
      const { data, error } = await supabase.from('platform_settings').select('key, value').in('key', ['support_phone', 'terms_and_conditions_ar'])
      if (error) throw error
      return Object.fromEntries(data.map((r) => [r.key, r.value])) as Record<string, string>
    },
  })

  useEffect(() => {
    if (settings) {
      setSupportPhone(settings.support_phone ?? '')
      setTerms(settings.terms_and_conditions_ar ?? '')
    }
  }, [settings])

  async function saveSettings() {
    setSaving(true)
    try {
      await Promise.all([
        supabase.from('platform_settings').update({ value: supportPhone }).eq('key', 'support_phone'),
        supabase.from('platform_settings').update({ value: terms }).eq('key', 'terms_and_conditions_ar'),
      ])
      show('تم حفظ التغييرات بنجاح')
    } catch {
      show('تعذّر حفظ الإعدادات', { isError: true })
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="flex flex-col gap-3.5">
      <div className="grid grid-cols-2 gap-3.5">
        <Card>
          <div className="mb-3 text-sm font-extrabold">حسابات المشرفين</div>
          {!admins || admins.length === 0 ? (
            <p className="py-2 text-xs text-neutral-500 dark:text-neutral-400">لا يوجد مشرفون مسجّلون بعد</p>
          ) : (
            admins.map((a) => (
              <div key={a.id} className="flex justify-between border-b border-neutral-100 py-2 last:border-0 dark:border-neutral-700">
                <span className="text-xs font-semibold">{a.full_name}</span>
                <span className="text-[11px] text-neutral-500 dark:text-neutral-400">مشرف</span>
              </div>
            ))
          )}
          <button
            onClick={() => show('يحتاج إنشاء مشرف جديد إلى Supabase Auth Admin API عبر Edge Function (غير مبنية بعد)', { isError: true })}
            className="mt-3 rounded-[10px] bg-green-900 px-4 py-2.5 text-xs font-bold text-white"
          >
            + إضافة مشرف
          </button>
        </Card>
        <Card>
          <div className="mb-3 text-sm font-extrabold">سجل نشاطات الإدارة (Audit Log)</div>
          {!auditLog || auditLog.length === 0 ? (
            <p className="py-2 text-xs text-neutral-500 dark:text-neutral-400">لا توجد نشاطات مسجّلة بعد</p>
          ) : (
            auditLog.map((entry) => (
              <div key={entry.id} className="border-b border-neutral-100 py-1.5 text-xs text-neutral-500 last:border-0 dark:border-neutral-700 dark:text-neutral-400">
                {entry.profiles?.full_name} — {entry.action} ({entry.target_table}) — {new Date(entry.created_at).toLocaleString('ar')}
              </div>
            ))
          )}
        </Card>
      </div>
      <Card>
        <div className="mb-3 text-sm font-extrabold">إعدادات عامة للمنصة</div>
        <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">أرقام تواصل الدعم (للسائقين والمطاعم)</label>
        <input
          value={supportPhone}
          onChange={(e) => setSupportPhone(e.target.value)}
          className="mb-3.5 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
        />
        <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">نص الشروط والأحكام</label>
        <textarea
          value={terms}
          onChange={(e) => setTerms(e.target.value)}
          className="min-h-25 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
        />
        <button
          onClick={saveSettings}
          disabled={saving}
          className="mt-3.5 rounded-[10px] bg-green-500 px-6 py-3 text-[13px] font-bold text-white disabled:opacity-60"
        >
          {saving ? '...' : 'حفظ التغييرات'}
        </button>
      </Card>
    </div>
  )
}
