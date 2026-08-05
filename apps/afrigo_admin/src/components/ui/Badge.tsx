import type { ReactNode } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '../../lib/cn'

const badgeVariants = cva('inline-flex items-center rounded-full px-3.5 py-1.5 text-xs font-bold', {
  variants: {
    status: {
      pending: 'bg-yellow-100 text-yellow-700',
      verified: 'bg-green-100 text-green-700',
      rejected: 'bg-error-surface-strong text-error',
      lowBalance: 'bg-yellow-100 text-yellow-700',
      offline: 'bg-neutral-100 text-neutral-500',
    },
  },
  defaultVariants: { status: 'pending' },
})

export interface BadgeProps extends VariantProps<typeof badgeVariants> {
  children: ReactNode
  className?: string
}

/** Status badge/pill — section 0.4 (شارات الحالة). Mirrors StatusBadge in afrigo_core. */
export function Badge({ status, children, className }: BadgeProps) {
  return <span className={cn(badgeVariants({ status }), className)}>{children}</span>
}
