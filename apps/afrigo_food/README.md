# Afrigo Food

Restaurant partner app — screens 61-72 from `Afrigo Food.dc.html`.

## What's wired to the real backend

- **Auth**: login/signup/sign-out call real Supabase Auth.
- **Verification** (screens 62/63): `submitRestaurantDocs`/`submitBikeDocs`
  really insert into `restaurants`/`vehicles` (`service_type='delivery'`);
  RLS + the `restaurants_guard` trigger force `status='pending'`.
- **Pending/Rejected** (screen 64): watches the restaurant row live via
  Supabase Realtime and auto-navigates once an admin actually reviews it.
- **Wallet balance**: real read + Realtime watch.
- **Menu management (screen 67) — fully real CRUD**: loads
  `restaurant_dish_categories`/`restaurant_dishes` for the owner's
  restaurant; add dish, toggle availability, toggle delivery-eligibility,
  and adjust stock all write straight back to Supabase.
- **Delivery settings**: persists to `restaurants.delivery_method` /
  `delivery_fee` / `min_order` / `prep_time_minutes` — new columns added in
  `supabase/migrations/20260801130001_restaurant_delivery_and_stock.sql`
  (not in the original table spec; needed for this screen to mean anything).

- **Open/closed toggle**: real `toggle-online-status` call.
- **Incoming orders / order detail** (screens 68/69) — fully real: a plain
  Realtime `.stream()` on `food_orders` filtered by `restaurant_id`,
  bucketed client-side into new/preparing/ready/done tabs (a food order is
  always tied to exactly one restaurant from creation, so — unlike
  taxi/livreur's fan-out-to-many-providers matching — there's no need for a
  Broadcast channel here; a table stream is simpler and sufficient). Accept/
  reject call `respond-to-order`; `preparing`→`ready` calls
  `update-order-status`, which server-side auto-dispatches a livreur search.

## What's still simulated

- **Reports** (screen 71): still the original design's static demo numbers
  — real aggregation would need its own query/RPC, not built in this pass.

## Run

```bash
flutter pub get
flutter run
```

Points at the real "Afrigo DB" Supabase project by default — see
`.env.example` / `lib/src/core/env.dart` to override.
