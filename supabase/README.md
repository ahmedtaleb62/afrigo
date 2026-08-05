# Afrigo — Supabase

Linked to the live **Afrigo DB** project (`ecbxpcxjfvlobduapctu`, West EU /
Ireland). Section 1 (SQL migrations) and Section 2 (Edge Functions) are both
done and deployed.

- `migrations/` — 21 migrations, applied in order: extensions/enums/helpers,
  then one file per entity (profiles, vehicles, restaurants+dishes, wallets,
  commission/pricing settings, rides+ride_locations, food_orders,
  delivery_requests, ratings, voice_orders, saved_addresses, notifications,
  admin_audit_log, platform_settings), then Section 2's supporting SQL:
  `increment_wallet_balance` / `find_nearby_vehicles` RPCs, the
  `all_orders_view`, the order-completion/commission-deduction triggers,
  the `admin_dashboard_stats` RPC, and `get_order_counterpart`. All 19 base
  tables, PostGIS GIST indexes, and RLS policies are live.
- `functions/` — 17 deployed Edge Functions (Deno/TypeScript), one folder
  each: `register-provider`, `toggle-online-status`, `review-verification`,
  `admin-topup-wallet`, `admin-suspend-user`, `calculate-fare`,
  `request-ride`, `request-food-order`, `request-delivery`,
  `respond-to-order`, `update-order-status`, `voice-order-transcribe`,
  `voice-order-parse-intent`, `voice-order-confirm`, `admin-dashboard-stats`,
  `delete-account`. (That's 16 folders against the original spec's "16
  functions" — `respond-to-order` also handles the livreur's food-delivery
  claim so there's no separate folder for that, and `delete-account` was
  added afterwards, outside the original spec, for the Client app's
  Settings screen. No standalone `submit-rating` function — see below.)
- `functions/_shared/` — `cors.ts`, `clients.ts` (service-role + caller
  clients, `requireUser`/`requireAdmin`), `handler.ts` (`withHandler`
  wrapper), `notify.ts` (in-app notification rows), `broadcast.ts`
  (Realtime Broadcast via REST), `fare.ts` (Distance Matrix + haversine
  fallback, fare calc, WKT helper).
- `.env` (gitignored) — holds `SUPABASE_ACCESS_TOKEN`, the project ref, URL
  and anon key used to drive the CLI / Management API for this project.

## Section 2 — what's real vs. deliberately out of scope

| Area | Status |
|---|---|
| Provider registration, online/offline toggle, admin verification/suspend/topup | Real, deployed |
| Ride/food/delivery request creation + PostGIS matching (3 km, broadcast-to-all-first-accept-wins) | Real, deployed |
| Accept/reject with optimistic locking (all 3 order types, incl. livreur claiming a food delivery leg) | Real, deployed |
| Status-machine transitions (`update-order-status`), incl. auto livreur search when a food order hits `ready` | Real, deployed |
| Commission deduction on order completion | Real — implemented as a **DB trigger**, not a callable function, so it can't be skipped or double-fired (see migration `20260802110001`) |
| Ratings | **No Edge Function** — `can_rate_order()` + the `ratings` RLS `INSERT` policy (Section 1) already fully validate eligibility, and there's no privileged side effect (no aggregate rating columns exist), so a wrapper function would only duplicate what RLS enforces |
| Voice ordering (transcribe / parse-intent / confirm) | Code-complete, deployed, and returns a clean `503` with an Arabic explanation — **no `GOOGLE_SPEECH_API_KEY` or `ANTHROPIC_API_KEY` is configured in this environment**, so the actual transcription/parsing calls have not been exercised end-to-end. Set both secrets (`supabase secrets set ...`) and it works with no code change. The **Client app's UI for this stayed unwired** on top of that — it also needs a real audio-recording package and a Storage bucket for the recording, neither of which exist yet (no bucket has been created in this project); see `apps/afrigo_client/README.md`. |
| Admin dashboard stats | Real, one SQL round trip (`admin_dashboard_stats` RPC) — **except** the Overview page's geographic-density heatmap, which needs a spatial-binning strategy sized to real order volume that doesn't exist on a fresh install |
| Push notifications (FCM) | Not implemented — only the `notifications` table row is created. No Flutter app has `firebase_messaging` wired in yet, and HTTP v1 FCM needs a service-account JWT nobody has provided |
| Account deletion (`delete-account`) | Real, deployed. Blocks while an order is in flight; hard-deletes `auth.users` when the account has no order history, otherwise falls back to a permanent login ban + PII scrub (`rides`/`food_orders`/`delivery_requests`/`ratings` deliberately have no cascading delete from `profiles` — they're audit/financial records) |
| Payment method (`cash`/`baridimob`/`bank_transfer`) | Real column on `rides`/`food_orders`/`delivery_requests` (migration `20260802150001`), populated by every `request-*` function — no real payment gateway, just a recorded choice |

All 17 functions were smoke-tested (expect a clean `401
{"error":"يجب تسجيل الدخول"}` on the ones requiring auth, never a 500) — see
git history for the curl commands.

## Design decisions beyond the literal table spec

- **`vehicles.is_online` / `current_location` / `location_updated_at`**: not
  in the original spec, but required for the PostGIS proximity search in
  `request-ride`/`request-delivery` (drivers need a live position + online
  flag somewhere; `profiles` has neither). Lives on `vehicles` since a
  provider only has a position once they have a verified vehicle.
- **Status-protecting triggers**: `vehicles`, `restaurants`, `profiles`,
  `notifications` all have a `BEFORE INSERT/UPDATE` trigger blocking
  non-`service_role` writes to their sensitive columns (`status`,
  `rejection_reason`, `reviewed_by`, `is_online`/`is_open`, `role`,
  `is_suspended`) — this is stricter than plain RLS since RLS alone can't
  do column-level restriction. Editing a verified/rejected vehicle's or
  restaurant's substantive fields auto-resets `status` to `pending`
  (screens 60/72).
- **`rides`/`food_orders`/`delivery_requests`**: RLS only grants `SELECT`
  to participants + admin. There is no client-side `INSERT`/`UPDATE` policy
  at all — every write (create, accept, status transition) goes through a
  `service_role` Edge Function per the spec's own state-machine requirement.
- **`ratings`**: `can_rate_order()` (SECURITY DEFINER) checks the order is
  `completed` and the rater was a party to it, reused by the RLS `INSERT`
  policy so this validation lives in one place.
- **Driver/restaurant contact info during an active order**: closed in
  Section 2 via `get_order_counterpart(order_type, order_id)` (migration
  `20260802130001`) — a SECURITY DEFINER RPC that returns only the handful
  of fields the tracking screens need (name, phone, vehicle plate) for the
  order's assigned counterpart, after checking the caller is that order's
  `client_id`. Callable directly by `authenticated` (no Edge Function
  needed — it's a pure read with no side effect, same reasoning as
  `can_rate_order()`).

## Decisions locked in
- Speech-to-text: Google Cloud Speech-to-Text.
- Default provider-search radius: 3 km (`platform_settings.provider_search_radius_km`).
- Order-acceptance timeout per provider: 20 seconds (`platform_settings.order_acceptance_timeout_seconds`).

## Housekeeping note

The linked project wasn't empty when I first connected — `public` had 7
orphaned enum types (`user_role`, `session_state`, `payment_method_enum`,
`payment_status_enum`, `dispute_status_enum`, `message_type_enum`,
`student_level_enum`) and one function (`current_role()`) left over from an
unrelated app, no tables. Confirmed with you and dropped them before
pushing Afrigo's schema.
