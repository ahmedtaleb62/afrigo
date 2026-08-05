import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { Card } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { EmptyState } from '../components/ui/EmptyState'
import { useToast } from '../components/ui/Toast'
import { supabase } from '../lib/supabase'
import { invokeFunction } from '../lib/functions'

const ROLE_LABEL: Record<string, string> = {
  client: 'عميل',
  taxi_driver: 'سائق تكسي',
  restaurant_owner: 'صاحب مطعم',
  livreur: 'عامل توصيل',
  admin: 'مشرف',
}

interface WalletRow {
  id: string
  balance: number
  low_balance_threshold: number
  owner_id: string
  profiles: { full_name: string; role: string } | null
}

interface Txn {
  id: string
  amount: number
  type: string
  note: string | null
  created_at: string
}

/**
 * Screen 86 — Wallets & Commissions. List/detail/transactions are real
 * (`wallets`, `wallet_transactions` — admin reads everything via RLS).
 * "إضافة رصيد يدوي" calls the real `admin-topup-wallet` Edge Function —
 * `balance` can only ever change via that service-role function, see
 * supabase/migrations/20260731230005_wallets.sql.
 */
export function WalletsPage() {
  const [detail, setDetail] = useState<WalletRow | null>(null)
  const [search, setSearch] = useState('')
  const [topupAmount, setTopupAmount] = useState('')
  const [topupNote, setTopupNote] = useState('')
  const [withdrawAmount, setWithdrawAmount] = useState('')
  const [withdrawNote, setWithdrawNote] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [withdrawing, setWithdrawing] = useState(false)
  const { show } = useToast()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data: wallets, isLoading } = useQuery({
    queryKey: ['wallets'],
    queryFn: async (): Promise<WalletRow[]> => {
      const { data, error } = await supabase
        .from('wallets')
        .select('id, balance, low_balance_threshold, owner_id, profiles(full_name, role)')
        .order('balance', { ascending: true })
      if (error) throw error
      return data as unknown as WalletRow[]
    },
  })

  const { data: txns } = useQuery({
    queryKey: ['wallet_transactions', detail?.id],
    enabled: !!detail,
    queryFn: async (): Promise<Txn[]> => {
      const { data, error } = await supabase
        .from('wallet_transactions')
        .select('id, amount, type, note, created_at')
        .eq('wallet_id', detail!.id)
        .order('created_at', { ascending: false })
        .limit(20)
      if (error) throw error
      return data
    },
  })

  async function submitTopup() {
    const amount = Number(topupAmount)
    if (!detail || !Number.isFinite(amount) || amount <= 0) {
      show('أدخل مبلغًا صالحًا', { isError: true })
      return
    }
    setSubmitting(true)
    try {
      await invokeFunction('admin-topup-wallet', {
        wallet_id: detail.id,
        amount,
        note: topupNote.trim() || undefined,
      })
      show('تم شحن الرصيد بنجاح')
      queryClient.invalidateQueries({ queryKey: ['wallets'] })
      queryClient.invalidateQueries({ queryKey: ['wallet_transactions', detail.id] })
      setDetail(null)
      setTopupAmount('')
      setTopupNote('')
    } catch (err) {
      show(err instanceof Error ? err.message : 'حدث خطأ، حاول مجددًا', { isError: true })
    } finally {
      setSubmitting(false)
    }
  }

  async function submitWithdraw() {
    const amount = Number(withdrawAmount)
    if (!detail || !Number.isFinite(amount) || amount <= 0) {
      show('أدخل مبلغًا صالحًا', { isError: true })
      return
    }
    setWithdrawing(true)
    try {
      await invokeFunction('admin-deduct-wallet', {
        wallet_id: detail.id,
        amount,
        note: withdrawNote.trim() || undefined,
      })
      show('تم سحب الرصيد بنجاح')
      queryClient.invalidateQueries({ queryKey: ['wallets'] })
      queryClient.invalidateQueries({ queryKey: ['wallet_transactions', detail.id] })
      setDetail(null)
      setWithdrawAmount('')
      setWithdrawNote('')
    } catch (err) {
      show(err instanceof Error ? err.message : 'حدث خطأ، حاول مجددًا', { isError: true })
    } finally {
      setWithdrawing(false)
    }
  }

  const filtered = wallets?.filter((w) => (w.profiles?.full_name ?? '').includes(search))

  if (detail) {
    return (
      <div>
        <button onClick={() => setDetail(null)} className="mb-3.5 text-xs font-bold text-neutral-500 dark:text-neutral-400">
          ‹ رجوع لقائمة المحافظ
        </button>
        <div className="grid grid-cols-[1.3fr_1fr] gap-4">
          <Card>
            <div className="mb-3.5 text-base font-extrabold">
              {detail.profiles?.full_name} — {ROLE_LABEL[detail.profiles?.role ?? ''] ?? detail.profiles?.role}
            </div>
            <div className="mb-4 text-[11px] text-neutral-500 dark:text-neutral-400">
              الرصيد الحالي: <span className="text-sm font-extrabold text-green-700">{detail.balance} أوقية</span>
            </div>
            <div className="mb-2 text-xs font-bold text-neutral-500 dark:text-neutral-400">سجل الحركات</div>
            {!txns || txns.length === 0 ? (
              <p className="py-4 text-xs text-neutral-500 dark:text-neutral-400">لا توجد حركات بعد</p>
            ) : (
              txns.map((t) => (
                <div key={t.id} className="flex justify-between border-b border-neutral-100 py-2.5 last:border-0 dark:border-neutral-700">
                  <span className="text-xs font-semibold">{t.note ?? (t.type === 'topup' ? 'شحن رصيد' : 'عمولة')}</span>
                  <span className={`text-xs font-bold ${t.amount < 0 ? 'text-error' : 'text-green-700'}`}>
                    {t.amount > 0 ? '+' : ''}
                    {t.amount} أوقية
                  </span>
                </div>
              ))
            )}
          </Card>
          <div className="flex flex-col gap-4">
          <Card>
            <div className="mb-2.5 text-[13px] font-bold">إضافة رصيد يدوي</div>
            <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">المبلغ (أوقية)</label>
            <input
              value={topupAmount}
              onChange={(e) => setTopupAmount(e.target.value)}
              placeholder="1000"
              className="mb-2.5 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
            />
            <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">ملاحظة</label>
            <input
              value={topupNote}
              onChange={(e) => setTopupNote(e.target.value)}
              placeholder="سبب الشحن"
              className="mb-3.5 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
            />
            <button disabled={submitting} onClick={submitTopup} className="w-full rounded-[10px] bg-green-500 py-3 text-[13px] font-bold text-white disabled:opacity-60">
              تنفيذ الشحن
            </button>
          </Card>
          <Card>
            <div className="mb-2.5 text-[13px] font-bold">سحب رصيد يدوي</div>
            <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">المبلغ (أوقية)</label>
            <input
              value={withdrawAmount}
              onChange={(e) => setWithdrawAmount(e.target.value)}
              placeholder="500"
              className="mb-2.5 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
            />
            <label className="mb-1 block text-[11px] font-semibold text-neutral-500 dark:text-neutral-400">ملاحظة</label>
            <input
              value={withdrawNote}
              onChange={(e) => setWithdrawNote(e.target.value)}
              placeholder="سبب السحب"
              className="mb-3.5 w-full rounded-[10px] border border-neutral-200 bg-neutral-50 px-2.5 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-900"
            />
            <button disabled={withdrawing} onClick={submitWithdraw} className="w-full rounded-[10px] bg-error py-3 text-[13px] font-bold text-white disabled:opacity-60">
              تنفيذ السحب
            </button>
          </Card>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div>
      <div className="mb-4 flex justify-between">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="بحث عن مزود..."
          className="w-70 rounded-[10px] border border-neutral-200 bg-white px-3 py-2.5 text-[13px] dark:border-neutral-700 dark:bg-neutral-800"
        />
        <button onClick={() => navigate('/wallets/settings')} className="rounded-[10px] bg-green-900 px-4.5 py-2.5 text-xs font-bold text-white">
          ⚙️ إعدادات العمولة والتسعير
        </button>
      </div>
      <Card className="overflow-hidden p-0">
        {isLoading ? (
          <div className="p-8 text-center text-sm text-neutral-500">جارٍ التحميل...</div>
        ) : !filtered || filtered.length === 0 ? (
          <EmptyState title="لا توجد محافظ بعد" message="ستظهر محافظ مزودي الخدمة هنا فور تسجيلهم" />
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                {['الاسم', 'النوع', 'الرصيد', 'الحالة'].map((h) => (
                  <th key={h} className="border-b border-neutral-200 px-4 py-3 text-right text-[11px] font-bold text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((w) => {
                const low = w.balance <= w.low_balance_threshold
                return (
                  <tr key={w.id} onClick={() => setDetail(w)} className="cursor-pointer">
                    <td className="border-b border-neutral-200 px-4 py-3 text-[13px] font-semibold dark:border-neutral-700">{w.profiles?.full_name ?? '—'}</td>
                    <td className="border-b border-neutral-200 px-4 py-3 text-xs text-neutral-500 dark:border-neutral-700 dark:text-neutral-400">
                      {ROLE_LABEL[w.profiles?.role ?? ''] ?? w.profiles?.role}
                    </td>
                    <td className={`border-b border-neutral-200 px-4 py-3 text-xs font-bold dark:border-neutral-700 ${low ? 'text-error' : ''}`}>{w.balance} أوقية</td>
                    <td className="border-b border-neutral-200 px-4 py-3 dark:border-neutral-700">
                      <Badge status={low ? 'lowBalance' : 'verified'}>{low ? 'رصيد منخفض' : 'نشط'}</Badge>
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
