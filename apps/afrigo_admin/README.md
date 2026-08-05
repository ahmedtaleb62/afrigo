# Afrigo Admin

Admin dashboard — screens 83-92 from `Afrigo Admin Dashboard.dc.html`.
React + TypeScript + Vite + Tailwind v4 + React Router + React Query +
Supabase.

## Bootstrapping the first admin account (required before you can log in)

Per the design's own login copy — "لا يوجد تسجيل عام — الحسابات تُنشأ يدويًا
من طرف الإدارة فقط" — there is no public admin signup. This project has no
admin account yet. To create one:

1. In the Supabase dashboard → Authentication → Users → **Add user**, create
   a user with an email/password.
2. In the SQL editor, insert their profile as an admin:
   ```sql
   insert into public.profiles (id, role, full_name, language_pref)
   values ('<the auth user''s UUID>', 'admin', 'اسمك', 'ar');
   ```
   (The `profiles_guard` trigger only lets `service_role` set `role` —
   running this as the `postgres`/SQL-editor role satisfies that.)
3. Log in with that email/password.

## What's real vs simulated

Everything **reads** real data (the admin's RLS grants full access via
`is_admin()`), and every write that needs a service-role Edge Function is
now wired to the real one (via `src/lib/functions.ts`'s `invokeFunction`
helper, which unwraps the function's `{"error": "..."}` JSON body into a
proper error message — `supabase.functions.invoke` doesn't do that itself):

| Screen | Read | Write |
|---|---|---|
| Overview | ✅ **real** — one call to `admin-dashboard-stats` per period tab, including revenue-over-time/orders-by-service/orders-by-hour/leaderboard/growth series | — |
| Verification | ✅ real (`vehicles`/`restaurants`) | ✅ **real** — `review-verification` |
| Wallets | ✅ real (`wallets`/`wallet_transactions`) | ✅ **real** — `admin-topup-wallet` |
| Commission & pricing | ✅ real | ✅ real — no service-role guard on these tables |
| Orders | ✅ real (`all_orders_view`) | n/a (read-only screen) |
| Voice orders | ✅ real (`voice_orders`) | n/a — playback needs the `voice-recordings` Storage bucket (not created — see `apps/afrigo_client/README.md`) |
| Users | ✅ real (`profiles`) | ✅ **real** — `admin-suspend-user` (writes `admin_audit_log` server-side) |
| Ratings | ✅ real (`ratings`) | n/a |
| Settings | ✅ real (admin list, `admin_audit_log`) | ✅ real for `platform_settings` (support phone, terms text); ❌ "+ إضافة مشرف" still needs the Supabase Auth Admin API via its own Edge Function (service_role only, never call it from the browser — not one of the 16 named in the original spec) |

The Overview page's geographic order-density card is still a static
placeholder — `admin_dashboard_stats` deliberately doesn't compute it; see
`supabase/README.md` for why.

## Run

```bash
npm install
npm run dev
```

Points at the real "Afrigo DB" Supabase project by default — see
`.env.example` / `src/lib/env.ts` to override.

> `npm audit` flags a "high" advisory in `react-router` — it's specific to
> RSC (React Server Components) mode, which this project doesn't use (plain
> client-side SPA via `BrowserRouter`); not applicable here.
