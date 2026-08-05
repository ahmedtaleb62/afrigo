import { createContext, useCallback, useContext, useState, type ReactNode } from 'react'
import { cn } from '../../lib/cn'

interface ToastMessage {
  id: number
  message: string
  isError: boolean
}

interface ToastContextValue {
  show: (message: string, options?: { isError?: boolean }) => void
}

const ToastContext = createContext<ToastContextValue | null>(null)

/** Toast — section 0.4 (Toast · Bottom Sheet). Auto-dismisses after 2.5s. */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastMessage[]>([])

  const show = useCallback((message: string, options?: { isError?: boolean }) => {
    const id = Date.now()
    setToasts((prev) => [...prev, { id, message, isError: options?.isError ?? false }])
    setTimeout(() => setToasts((prev) => prev.filter((t) => t.id !== id)), 2500)
  }, [])

  return (
    <ToastContext.Provider value={{ show }}>
      {children}
      <div className="fixed bottom-8 end-8 z-50 flex flex-col gap-2">
        {toasts.map((t) => (
          <div
            key={t.id}
            className={cn(
              'flex items-center gap-2.5 rounded-button bg-neutral-900 px-5.5 py-4 text-sm font-semibold text-white shadow-lg',
            )}
          >
            <span className={t.isError ? 'text-error' : 'text-green-300'}>{t.isError ? '⚠' : '✓'}</span>
            {t.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  )
}

export function useToast() {
  const ctx = useContext(ToastContext)
  if (!ctx) throw new Error('useToast must be used within a ToastProvider')
  return ctx
}
