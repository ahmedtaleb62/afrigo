import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../lib/auth'

export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { session, loading, isAdmin } = useAuth()

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center bg-neutral-50 dark:bg-neutral-900">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-green-200 border-t-green-500" />
      </div>
    )
  }

  if (!session || !isAdmin) return <Navigate to="/login" replace />

  return <>{children}</>
}
