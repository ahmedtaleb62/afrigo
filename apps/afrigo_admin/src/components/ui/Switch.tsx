import { cn } from '../../lib/cn'

export interface SwitchProps {
  checked: boolean
  onChange: (checked: boolean) => void
  onLabel: string
  offLabel: string
  className?: string
}

/** Online/offline switch — section 0.4 (Switch). */
export function Switch({ checked, onChange, onLabel, offLabel, className }: SwitchProps) {
  return (
    <div className={cn('flex flex-col items-start gap-2', className)}>
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        onClick={() => onChange(!checked)}
        className={cn(
          'box-border h-8 w-14 rounded-full p-[3px] transition-colors',
          checked ? 'bg-green-500' : 'bg-neutral-200',
        )}
      >
        <span
          className={cn(
            'block h-[26px] w-[26px] rounded-full bg-white transition-transform',
            checked ? 'translate-x-6 rtl:-translate-x-6' : 'translate-x-0',
          )}
        />
      </button>
      <span className={cn('text-sm font-bold', checked ? 'text-green-700' : 'text-neutral-500')}>
        {checked ? onLabel : offLabel}
      </span>
    </div>
  )
}
