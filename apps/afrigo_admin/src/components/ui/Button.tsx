import type { ButtonHTMLAttributes } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '../../lib/cn'

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 rounded-button font-bold text-[15px] transition-colors disabled:cursor-not-allowed disabled:bg-neutral-200 disabled:text-neutral-400',
  {
    variants: {
      variant: {
        primary: 'bg-green-500 text-white px-7 py-3.5 hover:bg-green-600',
        secondary:
          'bg-white text-green-700 border-2 border-green-500 px-6.5 py-3 hover:bg-green-50',
      },
    },
    defaultVariants: { variant: 'primary' },
  },
)

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean
}

/** Button component — section 0.4 (أزرار): primary, secondary, disabled, loading. */
export function Button({ variant, loading, className, children, disabled, ...props }: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant }), className)}
      disabled={disabled || loading}
      {...props}
    >
      {loading && (
        <span className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
      )}
      {children}
    </button>
  )
}
