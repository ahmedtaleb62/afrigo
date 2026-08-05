# Afrigo

Monorepo for the Afrigo platform: 4 Flutter apps (Client, Taxi, Food, Livreur)
+ a React admin panel, sharing one Supabase project.

## Layout

```
apps/
  afrigo_client/    Flutter — rider/customer app
  afrigo_taxi/       Flutter — taxi driver app
  afrigo_food/        Flutter — restaurant + food-delivery app
  afrigo_livreur/    Flutter — delivery courier app
  afrigo_admin/       React + TS + Vite + Tailwind — admin panel
packages/
  afrigo_core/        Flutter — shared design system, theme, widgets, l10n
supabase/
  migrations/         21 SQL migrations — live on the "Afrigo DB" project
  functions/           16 deployed Edge Functions — see supabase/README.md
```

## Status

**Done:**

- **Design system** from `Afrigo Design System.dc.html`, wired into all 5 apps:
  - `packages/afrigo_core`: color tokens, Tajawal/Manrope typography (ar/fr),
    `AfrigoTheme.light()`, shared widgets (button, text field, checkbox/radio/
    switch rows, status badge, toast, confirm bottom sheet, skeleton loader,
    empty state, bottom nav), the 4 app logos, and an ARB-based l10n scaffold
    (`AfrigoLocalizations`, ar + fr).
  - `apps/afrigo_admin`: matching Tailwind v4 tokens (`src/index.css`), the
    same 4 logos, and Button/Badge/Switch/EmptyState/Toast components.
  - Each of the 4 Flutter apps has a temporary home screen proving the theme,
    widgets and l10n are wired correctly — this will be replaced by each
    app's real screen 1 (Splash) once its screens are implemented.
- **Section 1 (database)**, live on the real Supabase project ("Afrigo DB",
  ref `ecbxpcxjfvlobduapctu`): all 19 tables, PostGIS + regular indexes, RLS
  on every table, status-machine-protecting triggers, and seed data for
  `commission_settings`/`pricing_settings`/`platform_settings`. Details and
  a few deliberate deviations from the literal spec (and why) are documented
  in `supabase/README.md`.
- **`apps/afrigo_client`** — all 44 screens (`Afrigo Client.dc.html`), real
  Supabase Auth + real permission prompts, real ride/parcel/food
  request+live-tracking+rating (see `apps/afrigo_client/README.md` for what
  remains simulated — mainly voice ordering, blocked on a real audio package
  + missing API keys).
- **`apps/afrigo_taxi`** — all 16 screens (`Afrigo Taxi.dc.html`), real
  Supabase Auth, real vehicle-doc submission + live Realtime status watch
  (screens 49/50), real wallet balance watch, real online toggle, real
  incoming-ride Realtime Broadcast + accept/reject + trip-status
  progression + rating (see `apps/afrigo_taxi/README.md`).
- **`apps/afrigo_food`** — all 16 screens (`Afrigo Food.dc.html`), real
  Supabase Auth, real restaurant+bike doc submission with live Realtime
  status watch, real wallet balance watch, **fully real menu management**
  (dish/category CRUD, availability, delivery-eligibility, stock), real
  open/closed toggle, and real incoming-order tracking (Realtime stream,
  not broadcast — see that README for why) + accept/reject/prep progression
  (see `apps/afrigo_food/README.md`). Added `restaurants.delivery_method/
  delivery_fee/min_order/prep_time_minutes` and
  `restaurant_dishes.available_for_delivery/stock_quantity` columns (not in
  the original table spec) to back this.
- **`apps/afrigo_livreur`** — all 15 screens (`Afrigo Livreur.dc.html`), real
  Supabase Auth, real vehicle-doc submission (`service_type='delivery'`)
  with live Realtime status watch, real wallet balance watch, real online
  toggle, and real incoming-delivery handling for **both** standalone
  parcels and the food-order second leg + two-leg trip flow + rating (see
  `apps/afrigo_livreur/README.md`).
- **`apps/afrigo_admin`** — all 10 screens (`Afrigo Admin Dashboard.dc.html`),
  React + React Router + React Query + Supabase. Real Auth with admin-role
  gating; **everything reads real data**, and every write that needs a
  service-role Edge Function is wired to the real one — verification
  approve/reject, wallet top-up, user suspend/activate, and the Overview
  page's full aggregation (revenue/orders/leaderboard/growth charts) all
  call live Edge Functions now. See `apps/afrigo_admin/README.md` —
  including how to bootstrap the first admin account, since there is no
  public admin signup.

All 5 apps (Client, Taxi, Food, Livreur, Admin) now have every screen from
their design files implemented, and every Section 2 Edge Function that has
a corresponding UI action is wired end-to-end from tap to database.

- **Section 2 (Edge Functions)**, live on the same Supabase project: all 16
  functions deployed and smoke-tested (provider registration, online/offline
  toggle, admin verification/wallet-topup/suspend, ride/food/delivery
  matching via PostGIS + Realtime Broadcast, accept/reject with optimistic
  locking, order status-machine transitions, commission deduction as a DB
  trigger, voice-order transcribe/parse/confirm, admin dashboard stats).
  Details, and what's genuinely real vs. still gated behind a missing API
  key (voice ordering needs `GOOGLE_SPEECH_API_KEY` + `ANTHROPIC_API_KEY`,
  neither configured in this environment), are in `supabase/README.md`.

**Remaining known gaps** (all documented in their respective READMEs, none
blocking the rest of the platform):
- Voice ordering's actual audio capture (`apps/afrigo_client`) — needs a
  real recording package + a Storage bucket, neither exists yet, and the
  transcription/parsing keys aren't configured regardless.
- A few read-only screens still show static demo data where wiring them was
  independent of Section 2 (Client app's Profile/Order History/
  Notifications; Food app's Reports; Admin's geographic order-density card).
- Real Google Maps is wired into `afrigo_client` (interactive pickup picker,
  real device location, real geocoded search — see its README); the other
  apps still use a documented Nouakchott-center placeholder pending the same
  integration.

Decisions locked in:
- Speech-to-text: **Google Cloud Speech-to-Text**.
- Default provider-search radius: **3 km**.
- Order-acceptance timeout per provider: **20 seconds**.

## Getting started

### Flutter apps

```bash
dart pub global activate melos   # once
melos bootstrap                  # or: flutter pub get (workspace-aware)
melos run analyze
melos run test
```

Run any app with `flutter run` from inside `apps/<app_name>`.

### Admin panel

```bash
cd apps/afrigo_admin
npm install
npm run dev
```

> Note: this repo's dev sandbox hit a native-binding install issue with the
> bleeding-edge Vite 8 (Rolldown) and with `oxlint`'s native binary — unrelated
> to app code. `apps/afrigo_admin/package.json` pins `vite@^6.4.3`, which
> builds and dev-serves cleanly. If `npx oxlint` fails with a
> `Cannot find module '@oxlint/binding-*'` error, run `npm rebuild` or
> reinstall `node_modules`.
