import { useState } from 'react'
import { Navigate } from 'react-router-dom'
import { Logo } from '../components/ui/Logo'
import { useAuth } from '../lib/auth'

export function LoginPage() {
  const { session, isAdmin, loading, signIn } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  if (session && isAdmin) return <Navigate to="/overview" replace />

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setSubmitting(true)
    setError(null)
    const { error: signInError } = await signIn(email, password)
    setSubmitting(false)
    if (signInError) setError(signInError)
    // If sign-in succeeds but the account isn't an admin, `AuthProvider`
    // resolves `isAdmin: false` once its profile fetch completes, and the
    // `showNotAdmin` banner below picks that up on the next render.
  }

  const showNotAdmin = session && !isAdmin && !loading

  return (
    <div
      dir="rtl"
      className="flex h-screen w-screen items-center justify-center bg-gradient-to-br from-green-900 to-green-700"
    >
      <div className="w-95 rounded-2xl bg-white p-10 shadow-2xl dark:bg-neutral-800">
        <div className="mb-7 flex items-center gap-2.5">
          <Logo app="client" size={36} />
          <span className="text-lg font-extrabold text-green-900 dark:text-white">Afrigo Admin</span>
        </div>
        <form onSubmit={handleSubmit}>
          <label className="mb-1.5 block text-xs font-semibold text-neutral-700 dark:text-neutral-300">البريد الإلكتروني</label>
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="admin@afrigo.com"
            className="mb-3.5 w-full rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-3 text-[13px] dark:border-neutral-700 dark:bg-neutral-900 dark:text-white"
          />
          <label className="mb-1.5 block text-xs font-semibold text-neutral-700 dark:text-neutral-300">كلمة المرور</label>
          <input
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            className="mb-2 w-full rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-3 text-[13px] dark:border-neutral-700 dark:bg-neutral-900 dark:text-white"
          />
          <p className="mb-5 text-[11px] text-neutral-400">لا يوجد تسجيل عام — الحسابات تُنشأ يدويًا من طرف الإدارة فقط</p>
          {error && <p className="mb-4 text-xs font-semibold text-error">{error}</p>}
          {showNotAdmin && (
            <p className="mb-4 text-xs font-semibold text-error">
              هذا الحساب غير مصرّح له بالوصول للوحة التحكم (ليس مشرفًا).
            </p>
          )}
          <button
            type="submit"
            disabled={submitting}
            className="w-full rounded-lg bg-green-500 py-3.5 text-sm font-bold text-white disabled:opacity-60"
          >
            {submitting ? '...' : 'دخول'}
          </button>
        </form>
      </div>
    </div>
  )
}
