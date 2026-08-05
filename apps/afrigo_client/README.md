# Afrigo Client

Rider/customer app — screens 1-44 from `Afrigo Client.dc.html`.

## What's wired to the real backend

- **Auth** (`src/state/client_flow_controller.dart`): login/signup/sign-out/
  forgot-password all call real Supabase Auth. Signup also calls
  `register-provider` (`role: 'client'`) at OTP-confirm time — the same
  point every sibling app calls it — creating the real `profiles`/`wallets`
  rows. (This call was missing until this pass; without it no client could
  ever place a real order — every `request-*` function 404s on a missing
  profile row.)
- **Profile**: real `profiles` row (name/email), with working "edit name"
  and "change password" actions. The Home screen's greeting uses the real
  first name too.
- **Permissions**: Location and Notification permission screens trigger real
  OS prompts via `permission_handler`.
- **Ride + parcel request/tracking/rating** (screens 12-20, 31-34): real
  `request-ride`/`request-delivery`, live Realtime tracking of the
  `rides`/`delivery_requests` row (auto-navigates through
  searching → provider found → tracking → trip end as the driver/livreur's
  own app advances the real status — this app never drives the status
  itself), `get_order_counterpart` for the assigned provider's name/phone/
  vehicle, cancel-after-accept via `update-order-status`
  (`cancelled_by_client`), and a real `ratings` insert. The vehicle-class
  picker and "note to driver" field are both real now too — sent as
  `vehicle_class`/`client_note` and stored on the `rides` row (previously
  collected in the UI and silently dropped).
- **Live driver/livreur location** (Tracking screen): the provider's own
  app broadcasts its position every 5s via Realtime Broadcast (channel
  `order_location:{orderType}:{orderId}`, no DB write) from the moment the
  order is `accepted` — `_subscribeDriverLocation` shows it as a real
  moving marker instead of the map just sitting on the static pickup pin
  for the whole trip. The provider-found/tracking screens' call (📞)
  buttons are real `tel:` intents now too — were decorative before.
- **Payment method**: cash / بنكيلي / سداد مصرفي — a real 3-way picker
  (`widgets/payment_method_field.dart`) recorded on the order row via a new
  `payment_method` column (migration `20260802150001_client_gaps.sql`). No
  real payment gateway exists or was asked for — this only records which
  one the client picked.
- **Food ordering** (screens 21-30): browsing is real — `restaurants`/
  `restaurant_dishes` reads replace the original design's single hardcoded
  demo restaurant. Checkout calls real `request-food-order` with real
  payment method + note; tracking is a live `food_orders` Realtime stream
  (client only watches, never advances a stage); a rejected order routes to
  the real rejection screen; completion inserts a real restaurant rating
  **and** a real livreur rating (the livreur's id is now captured off the
  live `food_orders` row — previously skipped entirely because nothing
  tracked it).
- **Order history**: real orders merged from `rides`/`food_orders`/
  `delivery_requests`, split into active/past by status.
- **Notifications**: real `notifications` rows, tap-to-mark-read.
- **Saved addresses** (Settings): real `saved_addresses` rows — add/delete
  work; new addresses use the same placeholder coordinate as everything
  else here (see below) rather than a real map pick.
- **Support screen**: WhatsApp/call buttons launch real `wa.me`/`tel:`
  intents (`Env.supportPhone` — a placeholder number until a real support
  line exists).
- **Delete account** (Settings): calls a new `delete-account` Edge
  Function. Blocks while an order is still in flight; otherwise hard-deletes
  the account, **unless** the account has any order history at all, in
  which case `rides`/`food_orders`/`delivery_requests`/`ratings`
  intentionally have no cascading delete from `profiles` (they're
  audit/financial records) — the function then falls back to permanently
  banning the login and scrubbing name/phone/email instead of erasing the
  order history.
- **Real Google Maps** (`widgets/real_map.dart`): `google_maps_flutter` +
  `geolocator` + `geocoding` are wired in.
  - `LocationPickerMap` — a real interactive map with a fixed center pin;
    drag the map, the pin's resting point is reverse-geocoded to a real
    address. Used on the ride-origin and parcel-pickup screens.
  - Destination/dropoff search (ride + parcel) does real forward geocoding
    (`ClientFlowController.searchDestination`) instead of just setting a
    display label with no coordinates behind it.
  - `LiveMapPreview` — a real (static/`liteMode`) map with markers, used
    everywhere a screen just needs to *show* a map (confirm/tracking/home)
    rather than let the user pick a point.
  - Real device location via `geolocator`, fetched right after the location
    permission is granted (and again on every Home screen load, covering
    permission already granted in a past session) — used as the pickup
    default and as the Home screen's own map center.
  - **Needs a real Maps API key to show actual tiles**:
    `android/app/src/main/res/values/maps_api_key.xml` has a placeholder —
    replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with a real key from Google
    Cloud Console (enable "Maps SDK for Android" for it; restricting it to
    package `com.example.afrigo_client` + a SHA-1 is optional but
    recommended — the debug keystore's SHA-1 is
    `57:3D:D1:7A:84:EF:B2:2C:D8:9D:28:4E:1B:BD:06:99:FF:34:03:8B`). Without
    a real key the map widgets still work (no crash), tiles just render
    blank/watermarked.
  - iOS isn't wired (no `AppDelegate`/`Info.plist` changes) — this pass
    targeted the Android device this project has been tested on.
  - Pickup/dropoff coordinates sent to the request functions still fall
    back to a fixed Nouakchott-center placeholder pair whenever nothing's been
    picked/geocoded yet (`ClientFlowController._resolvedPickup`/
    `_resolvedDropoff`) — same "graceful, not fake" approach used
    server-side when a Distance Matrix key is missing.
  - Food ordering's delivery address now uses the same real
    `LocationPickerMap` flow (`food_delivery_address_screen.dart`, reachable
    via the checkout screen's "تعديل" button) writing to the same
    `dropoffLat`/`dropoffLng`/`dropoffAddress` fields ride/parcel already
    used — `placeFoodOrder` reads them with the same current-location/
    placeholder fallback chain as everywhere else, instead of always
    sending the fixed placeholder regardless of what was shown on screen.

## What's still simulated / known gaps

- **Voice ordering** (screens 35-38): UI-only. Wiring it for real needs (a)
  a real audio-recording package + a Storage bucket for the recording
  (neither exists in this app/project yet), and (b)
  `GOOGLE_SPEECH_API_KEY`/`ANTHROPIC_API_KEY` configured on the Supabase
  project. Deferred by explicit agreement — revisit later.
- **OTP verification**: still not real (any 4 digits are accepted) — needs
  an SMS/email OTP provider (Twilio etc.) configured on the project.
  Deferred by explicit agreement.
- **Language toggle** (Settings): now persists to `profiles.language_pref`
  for real, but the app's own UI stays Arabic-only regardless — every
  screen's strings are hardcoded Arabic literals, not routed through
  `AppLocalizations` (which exists in `afrigo_core` but isn't used by any
  screen here). Actually supporting French would mean localizing ~2000
  strings across 44 screens — a separate, much larger pass, not attempted
  here.
- **Vehicle class** only affects what's recorded on the order, not driver
  matching/pricing — `find_nearby_vehicles` still matches by service type
  only, same as before. Building real fleet segmentation (separate
  economy/comfort driver pools + differentiated pricing) is a bigger
  feature than "stop silently dropping the field."
- **Push notifications**: the Notification permission screen still only
  requests the OS permission — there's no FCM/APNs integration behind it,
  so nothing is ever actually delivered. Needs a Firebase project + native
  config, out of scope here.
- About/Terms/Privacy (Settings) show real but non-legally-reviewed
  placeholder text — fine to ship as copy, not as actual legal terms.

## Run

```bash
flutter pub get
flutter run
```

Points at the real "Afrigo DB" Supabase project by default — see
`.env.example` / `lib/src/core/env.dart` to override. Set
`--dart-define=SUPPORT_PHONE=+222...` for a real support number.
