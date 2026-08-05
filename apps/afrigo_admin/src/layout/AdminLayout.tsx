import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { Logo } from '../components/ui/Logo'
import { useAuth } from '../lib/auth'
import { useDarkMode } from '../lib/useDarkMode'
import { NAV_ITEMS, PAGE_TITLES } from './nav'

export function AdminLayout() {
  const { signOut, profile } = useAuth()
  const { dark, toggle } = useDarkMode()
  const location = useLocation()
  const title = PAGE_TITLES[location.pathname] ?? ''

  return (
    <div dir="rtl" className="flex h-screen w-screen bg-neutral-50 text-neutral-900 dark:bg-neutral-900 dark:text-neutral-50">
      <aside className="flex w-59 flex-shrink-0 flex-col bg-green-900 p-3.5 text-white">
        <div className="flex items-center gap-2.5 px-2 pb-5.5 pt-2">
          <Logo app="client" size={28} />
          <span className="text-[15px] font-extrabold">Afrigo Admin</span>
        </div>
        <nav className="flex flex-col gap-1">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `flex items-center gap-2.5 rounded-[10px] px-3 py-2.5 text-[13px] font-semibold transition-colors ${
                  isActive ? 'bg-white/15' : 'hover:bg-white/5'
                }`
              }
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
        <div className="flex-1" />
        <button
          onClick={toggle}
          className="mb-1.5 flex items-center justify-between rounded-[10px] bg-white/8 px-3 py-2.5 text-xs font-semibold"
        >
          <span>🌙 الوضع الداكن</span>
          <span className={`box-border h-5 w-8.5 rounded-full p-0.5 transition-colors ${dark ? 'bg-green-500' : 'bg-white/20'}`}>
            <span className={`block h-4 w-4 rounded-full bg-white transition-transform ${dark ? '-translate-x-3.5' : ''}`} />
          </span>
        </button>
        <button onClick={signOut} className="px-3 py-2.5 text-right text-xs font-semibold text-yellow-400">
          تسجيل الخروج
        </button>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <header className="flex h-16 flex-shrink-0 items-center justify-between border-b border-neutral-200 bg-white px-7 dark:border-neutral-800 dark:bg-neutral-800">
          <h1 className="text-[17px] font-extrabold">{title}</h1>
          <div className="flex items-center gap-2.5">
            <span className="text-xs font-semibold text-neutral-500">عربي</span>
            <div className="flex h-8.5 w-8.5 items-center justify-center rounded-full bg-green-50 text-[15px] dark:bg-green-900/40">
              🧑‍💼
            </div>
            {profile && <span className="text-xs font-semibold">{profile.full_name}</span>}
          </div>
        </header>
        <main className="flex-1 overflow-auto p-6.5">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
