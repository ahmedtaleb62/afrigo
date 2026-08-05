export const NAV_ITEMS = [
  { to: '/overview', icon: '📊', label: 'نظرة عامة' },
  { to: '/verification', icon: '🪪', label: 'إدارة التوثيق' },
  { to: '/wallets', icon: '💳', label: 'المحافظ والعمولات' },
  { to: '/orders', icon: '🧾', label: 'الطلبات' },
  { to: '/voice-orders', icon: '🎙️', label: 'الطلبات الصوتية' },
  { to: '/users', icon: '👥', label: 'المستخدمون' },
  { to: '/ratings', icon: '⭐', label: 'التقييمات' },
  { to: '/settings', icon: '⚙️', label: 'الإعدادات العامة' },
] as const

export const PAGE_TITLES: Record<string, string> = {
  '/overview': 'نظرة عامة',
  '/verification': 'إدارة التوثيق',
  '/wallets': 'المحافظ والعمولات',
  '/wallets/settings': 'إعدادات العمولة والتسعير',
  '/orders': 'الطلبات',
  '/voice-orders': 'الطلبات الصوتية',
  '/users': 'المستخدمون',
  '/ratings': 'التقييمات',
  '/settings': 'الإعدادات العامة',
}
