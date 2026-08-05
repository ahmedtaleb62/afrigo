# Afrigo Livreur

Delivery courier app — screens 73-82 from `Afrigo Livreur.dc.html`.
Structurally close to `afrigo_taxi` (one vehicle to verify, one wallet, one
online switch, one incoming-request flow) — same wiring approach.

## What's wired to the real backend

- **Auth**: login/signup/sign-out call real Supabase Auth.
- **Vehicle verification** (screen 74): `submitVehicleDocs` really inserts
  into `vehicles` (`service_type='delivery'`); RLS + the `vehicles_guard`
  trigger force `status='pending'`.
- **Pending/Rejected** (screen 75): watches that vehicle row live via
  Supabase Realtime (already enabled on `vehicles` by `afrigo_taxi`'s
  migration — reused here, no new migration needed) and auto-navigates the
  moment an admin actually reviews it.
- **Wallet balance**: real read + Realtime watch.
- **Online toggle**: real `toggle-online-status` call.
- **Incoming delivery** (screen 76's bottom sheet): a livreur receives
  offers from **two** real sources on one Realtime channel
  (`delivery:{uid}:incoming_orders`) — standalone parcels (`request-delivery`,
  event `incoming_delivery`) and the second leg of a food order (a
  restaurant marking an order `ready`, event `incoming_food_delivery`, fetched
  and shown as a proper offer via a `food_orders`+`restaurants` join). Both
  are claimed via `respond-to-order`, optimistic-locked the same way.
- **Two-leg trip flow** (pickup → dropoff → end summary → rate customer):
  real `update-order-status` calls. Standalone parcels have an explicit
  `picked_up` step; the food-order leg doesn't (claiming it already moves it
  to `out_for_delivery`), so picking up from the restaurant is a local
  screen transition there — see the controller's doc comments for why.
  Commission deduction on completion is a DB trigger, not a callable
  function.
- **Rating**: real insert into `ratings` (livreur rates the client).

## What's still simulated

- Wallet transaction list and delivery History show the same static demo
  data as the original design — real reads are straightforward, just not
  wired here yet.

## Run

```bash
flutter pub get
flutter run
```

Points at the real "Afrigo DB" Supabase project by default — see
`.env.example` / `lib/src/core/env.dart` to override.
