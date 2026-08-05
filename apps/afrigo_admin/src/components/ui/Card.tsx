import type { HTMLAttributes, ReactNode } from 'react'
import { cn } from '../../lib/cn'

export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn('rounded-card-lg border border-neutral-200 bg-white p-4.5 dark:border-neutral-700 dark:bg-neutral-800', className)}
      {...props}
    />
  )
}

export function TabPill({ active, onClick, children }: { active: boolean; onClick: () => void; children: ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'rounded-lg px-4 py-2 text-xs font-bold transition-colors',
        active ? 'bg-green-900 text-white' : 'bg-neutral-100 text-neutral-500 dark:bg-neutral-700 dark:text-neutral-300',
      )}
    >
      {children}
    </button>
  )
}
