import { Button } from './Button'

export interface EmptyStateProps {
  title: string
  message: string
  emoji?: string
  actionLabel?: string
  onAction?: () => void
}

/** Empty state — section 0.4 (Empty State). */
export function EmptyState({ title, message, emoji = '📭', actionLabel, onAction }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center gap-1 rounded-card-lg bg-white p-8 text-center shadow-sm dark:bg-neutral-800">
      <span className="mb-1 text-4xl">{emoji}</span>
      <p className="font-bold text-neutral-900 dark:text-neutral-50">{title}</p>
      <p className="text-xs text-neutral-500">{message}</p>
      {actionLabel && onAction && (
        <Button variant="primary" onClick={onAction} className="mt-3 w-auto">
          {actionLabel}
        </Button>
      )}
    </div>
  )
}
