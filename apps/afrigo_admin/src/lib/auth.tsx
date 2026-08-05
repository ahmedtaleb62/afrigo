import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from './supabase'

interface AdminProfile {
  id: string
  full_name: string
  role: string
}

interface AuthState {
  session: Session | null
  profile: AdminProfile | null
  loading: boolean
  /** True once we've checked: signed in AND profiles.role === 'admin'. */
  isAdmin: boolean
  signIn: (email: string, password: string) => Promise<{ error: string | null }>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthState | null>(null)

/**
 * There is deliberately no public admin signup (per the design's own login
 * copy: "لا يوجد تسجيل عام — الحسابات تُنشأ يدويًا من طرف الإدارة فقط").
 * Until an admin row is created by hand in `profiles` (role='admin') for a
 * real `auth.users` account, every sign-in attempt will correctly fail the
 * `isAdmin` check below — see apps/afrigo_admin/README.md for how to bootstrap
 * the first admin.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<AdminProfile | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session)
      if (!data.session) setLoading(false)
    })
    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession)
      if (!newSession) {
        setProfile(null)
        setLoading(false)
      }
    })
    return () => sub.subscription.unsubscribe()
  }, [])

  useEffect(() => {
    if (!session) return
    let cancelled = false
    setLoading(true)
    supabase
      .from('profiles')
      .select('id, full_name, role')
      .eq('id', session.user.id)
      .maybeSingle()
      .then(({ data }) => {
        if (cancelled) return
        setProfile(data as AdminProfile | null)
        setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [session])

  const signIn: AuthState['signIn'] = async (email, password) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    return { error: error?.message ?? null }
  }

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  const isAdmin = profile?.role === 'admin'

  return (
    <AuthContext.Provider value={{ session, profile, loading, isAdmin, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider')
  return ctx
}
