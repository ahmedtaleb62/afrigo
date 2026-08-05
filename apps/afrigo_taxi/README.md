# Afrigo Taxi

Taxi driver app — screens 45-60 from `Afrigo Taxi.dc.html`.

## What's wired to the real backend

- **Auth** (`src/state/taxi_flow_controller.dart`): login/signup/sign-out
  call real Supabase Auth.
- **Vehicle verification** (screen 48): `submitVehicleDocs` really inserts
  into `vehicles` (`service_type='taxi'`); RLS + the `vehicles_guard`
  trigger force `status='pending'` no matter what the client sends.
- **Pending/Rejected** (screens 49/50): watch that vehicle row live via
  Supabase Realtime (`watchVehicleStatus`) and auto-navigate the moment an
  admin actually reviews it — no polling.
- **Wallet balance** (screens 51/53): real read + Realtime watch of
  `wallets.balance` (`watchWallet`).
- **Online toggle** (screen 51): real `toggle-online-status` call —
  server-side validates `status='verified'` + `wallet.balance > threshold`
  before flipping `vehicles.is_online`.
- **Incoming ride** (screen 51's bottom sheet): real Realtime Broadcast —
  subscribes to `driver:{uid}:incoming_orders`, event `incoming_ride`, the
  moment `request-ride` (Client app) matches this driver. Accept/reject call
  `respond-to-order` with optimistic locking (first driver to accept wins;
  others get a clear "another driver already accepted" toast).
- **Trip flow** (screens 55-58): `driver_arriving`/`in_progress`/`completed`
  transitions call real `update-order-status`; commission deduction on
  completion is a DB trigger (`complete-order-and-deduct-commission`'s SQL,
  not a callable function — see `supabase/README.md`). Trip-end summary
  shows the real distance/duration/price/commission-% from the accepted ride
  row and `commission_settings`.
- **Rating** (screen 58): real insert into `ratings` (driver rates the
  client) — RLS + `can_rate_order()` validate eligibility.
- **Live location broadcast**: from the moment a ride is accepted through
  trip completion, `_startBroadcastingLocation` sends this driver's
  position every 5s on `order_location:ride:{rideId}` (Realtime Broadcast,
  no DB write) — the Client app's Tracking screen shows it as a real
  moving marker. The Navigate-to-Pickup screen's call (📞) button is a
  real `tel:` intent now too — was decorative before.

- **Real Google Maps** (`widgets/real_map.dart`): `google_maps_flutter` +
  `geolocator` are wired in — replaces the old `MapPlaceholder` grid on the
  Home, Navigate-to-Pickup, and Trip-Ongoing screens. Home shows the
  driver's own live position; the other two show the real pickup/dropoff
  point (`rides.pickup_lat`/`pickup_lng`/`dropoff_lat`/`dropoff_lng` —
  plain numeric columns added alongside the PostGIS `geography` ones
  because PostgREST can't extract `st_x`/`st_y` in a `select()`; see
  `_shared/orders.ts`'s `createRide`) plus the driver's own live marker.
  Needs the same real Maps API key as the Client app
  (`android/app/src/main/res/values/maps_api_key.xml`) — reuses that exact
  key here.
- **Wallet شحن/سحب**: two buttons on the Wallet screen open WhatsApp
  (`Env.supportPhone`) with a prefilled message — no real payment gateway
  exists, so topping up/withdrawing is a manual admin action requested this
  way, same pattern as the Client app's Support screen.

- **Wallet transactions / Trip History / Home stats** — all real now.
  Wallet screen reads real `wallet_transactions`
  (`loadWalletTransactions`). Trip History and the Home screen's "رحلات
  اليوم"/"أرباح اليوم" cards both read `driver_trip_history()` — a
  SECURITY DEFINER RPC, not a plain `.select()` with a `profiles` embed,
  because `profiles_select_own_or_admin`'s RLS blocks a driver from reading
  an arbitrary client's name directly (same gap `get_order_counterpart`
  closes for a single *active* order — this is the bulk-history
  equivalent). Today's stats are derived client-side from the subset of
  that history completed today, refreshed after every trip ends.

## Run

```bash
flutter pub get
flutter run
```

Points at the real "Afrigo DB" Supabase project by default — see
`.env.example` / `lib/src/core/env.dart` to override.
