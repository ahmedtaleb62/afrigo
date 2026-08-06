import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/push_notifications.dart';
import 'cart_item.dart';
import 'client_flow_state.dart';
import 'client_screen.dart';

final clientFlowControllerProvider =
    StateNotifierProvider<ClientFlowController, ClientFlowState>(
  (ref) => ClientFlowController(),
);

/// `google_maps_flutter`/`geolocator`/`geocoding` are now wired in (real
/// map pickers on origin/pickup screens, real device location, real
/// geocoded destination search — see `real_map.dart`), but a request still
/// needs *some* {lat,lng} pair even before the user has picked anything or
/// granted location, or if a real Maps API key isn't configured yet in
/// this environment (see `android/app/src/main/res/values/maps_api_key.xml`)
/// — these two fixed Nouakchott-center points are the fallback for that case.
/// `calculateFare` (server-side) falls back to a haversine estimate when
/// there's no Google Distance Matrix key either, so this still produces a
/// real, if not always geographically accurate, fare and PostGIS match —
/// same "graceful degradation, not a fake number" approach used throughout
/// Section 2.
const _placeholderPickup = {'lat': 18.0858, 'lng': -15.9785};
const _placeholderDropoff = {'lat': 18.0950, 'lng': -15.9650};

FoodStage? _statusToFoodStage(String? status) {
  switch (status) {
    case 'pending_restaurant':
      return FoodStage.waiting;
    case 'accepted':
      return FoodStage.accepted;
    case 'preparing':
      return FoodStage.preparing;
    case 'ready':
    case 'searching_livreur':
    case 'no_livreur_found':
      return FoodStage.ready;
    case 'out_for_delivery':
      return FoodStage.onway;
    case 'delivered':
    case 'completed':
      return FoodStage.delivered;
    default:
      return null;
  }
}

/// Ports the original design prototype's `Component` class 1:1: same
/// screen/history stack, same field names. Auth and permission requests hit
/// real Supabase Auth / OS dialogs. The ride/food/delivery request +
/// tracking flows now call the real Section 2 Edge Functions
/// (`request-ride`/`request-food-order`/`request-delivery`,
/// `update-order-status` results watched live via Realtime) instead of the
/// original prototype's fake timers. Voice ordering stays UI-only — it
/// needs a real audio-recording package + a Storage bucket (neither exists
/// yet) and the `voice-order-transcribe`/`-parse-intent` functions have no
/// `GOOGLE_SPEECH_API_KEY`/`ANTHROPIC_API_KEY` configured in this
/// environment regardless — see supabase/README.md and
/// apps/afrigo_client/README.md.
class ClientFlowController extends StateNotifier<ClientFlowState> {
  ClientFlowController() : super(const ClientFlowState());

  Timer? _voiceTimer;
  Timer? _searchTimeoutTimer;
  StreamSubscription<List<Map<String, dynamic>>>? _orderSub;
  StreamSubscription<List<Map<String, dynamic>>>? _foodOrderSub;
  RealtimeChannel? _locationChannel;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void dispose() {
    _voiceTimer?.cancel();
    _searchTimeoutTimer?.cancel();
    _orderSub?.cancel();
    _foodOrderSub?.cancel();
    _unsubscribeDriverLocation();
    super.dispose();
  }

  /// The assigned driver/livreur's own app broadcasts its live position
  /// directly on this channel (no server round-trip — see
  /// `TaxiFlowController._startBroadcastingLocation`); the client just
  /// listens. `orderType` is `ride`/`delivery_request`, matching
  /// `_subscribeOrderTracking`'s.
  void _subscribeDriverLocation(String orderType, String orderId) {
    _unsubscribeDriverLocation();
    _locationChannel = _sb.channel('order_location:$orderType:$orderId')
      ..onBroadcast(
        event: 'location',
        callback: (payload) {
          final lat = (payload['lat'] as num?)?.toDouble();
          final lng = (payload['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) state = state.copyWith(driverLat: lat, driverLng: lng, driverLocationUpdatedAt: DateTime.now());
        },
      )
      ..subscribe();
  }

  void _unsubscribeDriverLocation() {
    if (_locationChannel != null) {
      _sb.removeChannel(_locationChannel!);
      _locationChannel = null;
    }
    state = state.copyWith(driverLat: null, driverLng: null, driverLocationUpdatedAt: null);
  }

  void goTo(ClientScreen screen, {ClientFlowState Function(ClientFlowState)? patch}) {
    final withHist = state.copyWith(hist: [...state.hist, state.screen]);
    state = patch != null ? patch(withHist).copyWith(screen: screen) : withHist.copyWith(screen: screen);
  }

  void back() {
    final hist = [...state.hist];
    final prev = hist.isNotEmpty ? hist.removeLast() : ClientScreen.home;
    state = state.copyWith(screen: prev, hist: hist);
  }

  void clearRequestError() => state = state.copyWith(requestError: null);

  /// `FunctionException.details` is the parsed JSON error body
  /// (`{"error": "..."}`) whenever the Edge Function returned one — see
  /// `_shared/handler.ts`. Falls back to a generic Arabic message otherwise.
  String _functionErrorMessage(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) return details['error'] as String;
    }
    return 'حدث خطأ، حاول مجددًا';
  }

  // ---------------------------------------------------------------------
  // Splash / language / onboarding
  // ---------------------------------------------------------------------
  static const onboardSteps = [
    (emoji: '🚕', title: 'تنقّل بثقة', desc: 'اطلب تكسي في ثوانٍ مع سائقين موثّقين وأسعار واضحة قبل الانطلاق'),
    (emoji: '🍔', title: 'اطلب طعامك المفضّل', desc: 'تصفّح مئات المطاعم القريبة واطلب وجبتك بضغطة زر'),
    (emoji: '📦', title: 'أرسل واستلم طرودك', desc: 'توصيل سريع وآمن لأي طرد داخل مدينتك'),
  ];

  void pickLang(String lang) => state = state.copyWith(langPick: lang);

  void onboardNext() {
    if (state.onboardStep >= 2) {
      goTo(ClientScreen.login);
    } else {
      state = state.copyWith(onboardStep: state.onboardStep + 1);
    }
  }

  // ---------------------------------------------------------------------
  // Auth — real Supabase calls
  // ---------------------------------------------------------------------
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setConfirmPassword(String v) => state = state.copyWith(confirmPassword: v);
  void setFullName(String v) => state = state.copyWith(fullName: v);
  void togglePass() => state = state.copyWith(showPass: !state.showPass);

  Future<void> doLogin() async {
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      await _sb.auth.signInWithPassword(email: state.email.trim(), password: state.password);
      state = state.copyWith(isSubmitting: false);
      unawaited(_ensureProfile());
      unawaited(PushNotifications.register());
      unawaited(loadPlatformSettings());
      await _routeAfterAuth();
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تسجيل الدخول، حاول مجددًا');
    }
  }

  /// Splash's "متابعة" used to always go to language-select, even with a
  /// persisted Supabase session — forcing a returning, already-logged-in
  /// user back through langSelect/onboarding/login every time the app
  /// process restarted. If a session already exists, skip straight to the
  /// same post-auth routing `doLogin()` uses.
  Future<void> continueFromSplash() async {
    if (_sb.auth.currentSession != null) {
      unawaited(_ensureProfile());
      unawaited(PushNotifications.register());
      unawaited(loadPlatformSettings());
      await _routeAfterAuth();
    } else {
      goTo(ClientScreen.langSelect);
    }
  }

  /// `support_phone`/`terms_and_conditions_ar`/`privacy_policy_ar`/`about_ar`
  /// were already admin-editable in `platform_settings`, but nothing ever
  /// read them here — every screen still used a hardcoded --dart-define
  /// support number and hardcoded dialog text that the admin panel's own
  /// edits had zero effect on.
  Future<void> loadPlatformSettings() async {
    try {
      final rows = await _sb.from('platform_settings').select('key, value');
      state = state.copyWith(platformSettings: {for (final r in rows) r['key'] as String: r['value']});
    } catch (_) {
      // Non-fatal — screens fall back to placeholder text/number.
    }
  }

  /// Re-attaches an active ride/delivery after login/resume — without this,
  /// a client who force-closed the app mid-ride (crash, OS kill, battery)
  /// lost all trace of it: no tracking, no driver contact, no way back in
  /// except waiting for it to just resolve with zero visibility. Food
  /// orders aren't covered by this resume path yet (separate screens/
  /// subscription, out of scope for this pass).
  Future<void> _routeAfterAuth() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(ClientScreen.langSelect);
      return;
    }
    try {
      final rideRows = await _sb
          .from('rides')
          .select()
          .eq('client_id', uid)
          .inFilter('status', ['searching', 'accepted', 'driver_arriving', 'in_progress'])
          .order('created_at', ascending: false)
          .limit(1);
      if (rideRows.isNotEmpty) {
        await _resumeActiveOrder(rideRows.first, 'rides', 'ride', ClientFlowType.taxi);
        return;
      }
      final deliveryRows = await _sb
          .from('delivery_requests')
          .select()
          .eq('client_id', uid)
          .inFilter('status', ['searching', 'accepted', 'picked_up'])
          .order('created_at', ascending: false)
          .limit(1);
      if (deliveryRows.isNotEmpty) {
        await _resumeActiveOrder(deliveryRows.first, 'delivery_requests', 'delivery_request', ClientFlowType.delivery);
        return;
      }
    } catch (_) {
      // Falls through to Home below — same as finding nothing active.
    }
    goTo(ClientScreen.home);
  }

  Future<void> _resumeActiveOrder(
    Map<String, dynamic> row,
    String table,
    String orderType,
    ClientFlowType flowType,
  ) async {
    final id = row['id'] as String;
    final status = row['status'] as String;
    state = state.copyWith(
      flowType: flowType,
      activeOrderId: id,
      activeOrderStatus: status,
      orderDistanceKm: (row['distance_km'] as num?)?.toDouble(),
      orderDurationMin: (row['duration_min'] as num?)?.toDouble(),
      orderPrice: (row['price'] as num?)?.toDouble(),
    );
    _subscribeOrderTracking(table, id, orderType);
    if (status == 'searching') {
      goTo(ClientScreen.searching);
      _armSearchTimeout();
    } else {
      final providerId = (row['driver_id'] ?? row['livreur_id']) as String?;
      state = state.copyWith(providerId: providerId);
      unawaited(_fetchProviderContact(orderType, id));
      _subscribeDriverLocation(orderType, id);
      goTo(ClientScreen.providerFound);
    }
  }

  /// Self-heals accounts stuck with an `auth.users` row but no `profiles`/
  /// `wallets` row — real accounts hit this in testing when the OTP-confirm
  /// step's `register-provider` call raced a network blip and silently
  /// failed, leaving the user able to log in but hard-blocked the moment
  /// any real request touched `assertNotSuspended` ("الملف الشخصي غير
  /// موجود"). `register-provider` is idempotent (returns immediately if a
  /// profile already exists), so calling it again on every login is cheap
  /// and never overwrites real data.
  Future<void> _ensureProfile() async {
    try {
      final fullName = _sb.auth.currentUser?.userMetadata?['full_name'] as String? ?? '';
      await _sb.functions.invoke('register-provider', body: {'role': 'client', 'full_name': fullName.trim().isEmpty ? 'مستخدم' : fullName});
    } catch (_) {
      // Non-fatal — same reasoning as the OTP-confirm call site.
    }
  }

  Future<void> doSignup() async {
    if (state.password != state.confirmPassword) {
      state = state.copyWith(authError: 'كلمتا المرور غير متطابقتين');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // Only creates the auth.users row. `register-provider` isn't relevant
      // here (that's for providers) — a client's `profiles`/`wallets` rows
      // need their own creation path; for now this mirrors the design's own
      // behavior (screens reading `profiles` show placeholder data until
      // that's wired).
      await _sb.auth.signUp(
        email: state.email.trim(),
        password: state.password,
        data: {'full_name': state.fullName},
      );
      state = state.copyWith(isSubmitting: false);
      goTo(ClientScreen.otp);
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إنشاء الحساب، حاول مجددًا');
    }
  }

  Future<void> signOut() async {
    await _orderSub?.cancel();
    await _foodOrderSub?.cancel();
    await _sb.auth.signOut();
    state = const ClientFlowState();
  }

  void setOtpDigit(int index, String value) {
    final otp = [...state.otp];
    otp[index] = value;
    state = state.copyWith(otp: otp);
  }

  /// The original prototype never actually validates the OTP either — it
  /// just advances. Real SMS/email OTP verification needs a provider
  /// (Twilio, etc.) configured on the Supabase project, which isn't set up
  /// yet; wire `Supabase.instance.client.auth.verifyOTP(...)` here once it is.
  ///
  /// What isn't optional: every sibling app (taxi/food/livreur) calls
  /// `register-provider` at this exact point to create the `profiles`/
  /// `wallets` rows for the just-confirmed signup — this app was missing
  /// that call entirely, which meant a client's `profiles` row never
  /// existed, and every real order request would fail with "الملف الشخصي
  /// غير موجود" (`assertNotSuspended` in every request-* function requires
  /// one). `role: 'client'` is a valid `register-provider` role.
  Future<void> confirmOtp() async {
    try {
      await _sb.functions.invoke('register-provider', body: {'role': 'client', 'full_name': state.fullName});
    } catch (_) {
      // Non-fatal — register-provider is idempotent, and every screen
      // that needs profiles/wallets data already tolerates it being
      // missing; the user isn't blocked from proceeding either way.
    }
    goTo(ClientScreen.locationPermission);
  }

  /// Forgot-password is a single screen with 3 inline steps (request code →
  /// verify code → set new password), matching the new design — same real
  /// Supabase calls as before, just no longer spread across dedicated
  /// screens/the shared OTP screen.
  void goToForgot() => goTo(ClientScreen.forgot, patch: (s) => s.copyWith(forgotStep: 0, fpEmail: '', fpCode: '', fpNewPassword: ''));

  void setFpEmail(String v) => state = state.copyWith(fpEmail: v);
  void setFpCode(String v) => state = state.copyWith(fpCode: v);
  void setFpNewPassword(String v) => state = state.copyWith(fpNewPassword: v);

  Future<void> sendResetCode() async {
    try {
      await _sb.auth.resetPasswordForEmail(state.fpEmail.trim());
    } catch (_) {
      // Best-effort — Supabase intentionally doesn't reveal whether the
      // email exists, so we still advance either way, same as the design.
    }
    state = state.copyWith(forgotStep: 1);
  }

  /// The original prototype never actually validates the reset code either
  /// — it just advances (same as signup OTP, see `confirmOtp`).
  void verifyResetCode() => state = state.copyWith(forgotStep: 2);

  Future<void> resetPasswordDone() async {
    try {
      if (state.fpNewPassword.isNotEmpty) {
        await _sb.auth.updateUser(UserAttributes(password: state.fpNewPassword));
      }
    } catch (_) {
      // Ignore — user still lands back on Login either way, matching the design.
    }
    goTo(ClientScreen.login);
  }

  // ---------------------------------------------------------------------
  // Permissions — real OS prompts
  // ---------------------------------------------------------------------
  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) unawaited(fetchCurrentLocation());
    goTo(ClientScreen.notifPermission);
  }

  /// Real device GPS fix — was requested via `permission_handler` but never
  /// actually read anywhere before this; every request used the fixed
  /// placeholder unconditionally regardless of permission state. Silently
  /// gives up if the permission isn't granted or the location service is
  /// off (e.g. re-entering the app later without re-running onboarding) —
  /// callers already fall back to the placeholder when `currentLat`/`Lng`
  /// stay null.
  Future<void> fetchCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      state = state.copyWith(currentLat: pos.latitude, currentLng: pos.longitude);
    } catch (_) {
      // Non-fatal — every caller already falls back to the placeholder.
    }
  }

  /// `isUserAction` defaults to true for every direct caller (picking a
  /// saved place, a search result) — only `LocationPickerMap`'s automatic
  /// mount/re-center resolves pass `false`, so those never flip
  /// `pickupIsUserSet` and a fresher GPS fix can still take over (see
  /// `RideOriginScreen` and the field's doc comment in `client_flow_state`).
  void setPickupLocation(double lat, double lng, String address, {bool isUserAction = true}) =>
      state = state.copyWith(
        pickupLat: lat,
        pickupLng: lng,
        pickupAddress: address,
        pickupIsUserSet: isUserAction ? true : state.pickupIsUserSet,
      );

  void setDropoffLocation(double lat, double lng, String address, {bool isUserAction = true}) =>
      state = state.copyWith(dropoffLat: lat, dropoffLng: lng, dropoffAddress: address, rideDest: address);

  /// Real forward geocoding for the destination/dropoff search fields
  /// (`ride_destination_screen`/`parcel_dropoff_screen`) — previously just
  /// set a display label with no real coordinates behind it at all.
  Future<bool> searchDestination(String query) async {
    if (query.trim().isEmpty) return false;
    try {
      final locations = await locationFromAddress(query.trim());
      if (locations.isEmpty) return false;
      final loc = locations.first;
      setDropoffLocation(loc.latitude, loc.longitude, query.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }

  /// Calls the same `calculate-fare` function (real Google Distance Matrix
  /// road distance, haversine fallback — see `_shared/fare.ts`) that
  /// `request-ride`/`request-delivery` use to compute the actual bill.
  /// Previously this mirrored the *old*, pre-Google-key haversine formula
  /// client-side, so once the server switched to real road distance the
  /// quoted estimate became a systematic underestimate of the real charge —
  /// straight-line distance is never longer than the real route. Calling the
  /// real function keeps the preview and the bill computed the same way.
  /// Falls back to the local haversine estimate only if the function call
  /// itself fails (offline, cold start) so the screen still shows *a*
  /// number rather than nothing.
  Future<void> loadFareEstimate({
    required String serviceType,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    state = state.copyWith(fareEstimateLoading: true);
    try {
      final res = await _sb.functions.invoke('calculate-fare', body: {
        'service_type': serviceType,
        'pickup': {'lat': pickupLat, 'lng': pickupLng},
        'dropoff': {'lat': dropoffLat, 'lng': dropoffLng},
      });
      final data = res.data as Map;
      state = state.copyWith(
        fareEstimateDistanceKm: (data['distance_km'] as num).toDouble(),
        fareEstimateDurationMin: (data['duration_min'] as num).toDouble(),
        fareEstimatePrice: (data['price'] as num).toDouble(),
        fareEstimateLoading: false,
      );
    } catch (_) {
      await _loadFareEstimateFallback(
        serviceType: serviceType,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
      );
    }
  }

  Future<void> _loadFareEstimateFallback({
    required String serviceType,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      final row = await _sb.from('pricing_settings').select('base_fare, price_per_km, price_per_min').eq('service_type', serviceType).single();
      final distanceKm = _haversineKm(pickupLat, pickupLng, dropoffLat, dropoffLng);
      final durationMin = (distanceKm / 30) * 60;
      final baseFare = (row['base_fare'] as num).toDouble();
      final perKm = (row['price_per_km'] as num).toDouble();
      final perMin = (row['price_per_min'] as num).toDouble();
      final price = baseFare + distanceKm * perKm + durationMin * perMin;
      state = state.copyWith(
        fareEstimateDistanceKm: distanceKm,
        fareEstimateDurationMin: durationMin,
        fareEstimatePrice: price,
        fareEstimateLoading: false,
      );
    } catch (_) {
      state = state.copyWith(fareEstimateLoading: false);
    }
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
    goTo(ClientScreen.home);
  }

  // ---------------------------------------------------------------------
  // Ride / parcel — real `request-ride` / `request-delivery` + Realtime
  // tracking + `get_order_counterpart` + rating insert
  // ---------------------------------------------------------------------
  void setRideDest(String v) => state = state.copyWith(rideDest: v);
  void selectVehicle(String v) => state = state.copyWith(rideVehicle: v);
  void setRecipientName(String v) => state = state.copyWith(recipientName: v);
  void setRecipientPhone(String v) => state = state.copyWith(recipientPhone: v);
  void setParcelNotes(String v) => state = state.copyWith(parcelNotes: v);
  void setPaymentMethod(String v) => state = state.copyWith(paymentMethod: v);
  void setOrderNote(String v) => state = state.copyWith(orderNote: v);

  /// Real pickup/dropoff once picked on a map or resolved via geocoding —
  /// falls back to the fixed placeholder pair for whichever half wasn't
  /// picked yet (e.g. `_placeholderDropoff` if the client never opened the
  /// destination search), same "graceful degradation" reasoning as
  /// `currentLat`/`Lng`.
  Map<String, double> get _resolvedPickup => {
        'lat': state.pickupLat ?? state.currentLat ?? _placeholderPickup['lat']!,
        'lng': state.pickupLng ?? state.currentLng ?? _placeholderPickup['lng']!,
      };
  Map<String, double> get _resolvedDropoff => {
        'lat': state.dropoffLat ?? _placeholderDropoff['lat']!,
        'lng': state.dropoffLng ?? _placeholderDropoff['lng']!,
      };

  Future<void> startSearch() async {
    goTo(ClientScreen.searching);
    state = state.copyWith(requestError: null);
    try {
      if (state.flowType == ClientFlowType.taxi) {
        final res = await _sb.functions.invoke('request-ride', body: {
          'pickup': _resolvedPickup,
          'pickup_address': state.pickupAddress ?? 'موقعي الحالي',
          'dropoff': _resolvedDropoff,
          'dropoff_address': state.dropoffAddress ?? (state.rideDest.isEmpty ? 'الوجهة المحددة' : state.rideDest),
          'vehicle_class': state.rideVehicle,
          'payment_method': state.paymentMethod,
          if (state.orderNote.trim().isNotEmpty) 'client_note': state.orderNote.trim(),
        });
        final data = res.data as Map;
        if (data['status'] == 'no_driver_found') {
          goTo(ClientScreen.noProvider);
          return;
        }
        state = state.copyWith(
          activeOrderId: data['ride_id'] as String,
          activeOrderStatus: 'searching',
          orderDistanceKm: (data['distance_km'] as num?)?.toDouble(),
          orderDurationMin: (data['duration_min'] as num?)?.toDouble(),
          orderPrice: (data['price'] as num?)?.toDouble(),
        );
        _subscribeOrderTracking('rides', data['ride_id'] as String, 'ride');
        _armSearchTimeout();
      } else {
        final res = await _sb.functions.invoke('request-delivery', body: {
          'pickup': _resolvedPickup,
          'pickup_address': state.pickupAddress ?? 'نقطة الاستلام',
          'dropoff': _resolvedDropoff,
          'dropoff_address': state.dropoffAddress ?? 'نقطة التسليم',
          'recipient_name': state.recipientName.trim(),
          'recipient_phone': state.recipientPhone.trim(),
          'package_type': state.parcelType,
          'package_notes': state.parcelNotes.trim().isEmpty ? null : state.parcelNotes.trim(),
          'payment_method': state.paymentMethod,
        });
        final data = res.data as Map;
        if (data['status'] == 'no_livreur_found') {
          goTo(ClientScreen.noProvider);
          return;
        }
        state = state.copyWith(
          activeOrderId: data['delivery_id'] as String,
          activeOrderStatus: 'searching',
          orderDistanceKm: (data['distance_km'] as num?)?.toDouble(),
          orderPrice: (data['price'] as num?)?.toDouble(),
        );
        _subscribeOrderTracking('delivery_requests', data['delivery_id'] as String, 'delivery_request');
        _armSearchTimeout();
      }
    } catch (e) {
      state = state.copyWith(requestError: _functionErrorMessage(e));
      goTo(ClientScreen.noProvider);
    }
  }

  /// Without this, "جارٍ البحث عن سائق" stayed on screen forever if no
  /// provider ever accepted — the broadcast that wakes a matched
  /// driver/livreur's app is genuinely fire-and-forget (nothing server-side
  /// ever marks the order as failed on its own), so the client has to be
  /// the one that gives up after a reasonable wait. Matches the design's
  /// own copy ("قد يستغرق الأمر بضع ثوانٍ") — 45s is well past that.
  void _armSearchTimeout() {
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = Timer(const Duration(seconds: 45), () {
      if (state.screen != ClientScreen.searching) return;
      _orderSub?.cancel();
      unawaited(_cancelActiveOrderOnServer());
      state = state.copyWith(activeOrderId: null, activeOrderStatus: null);
      goTo(ClientScreen.noProvider);
    });
  }

  /// `rides`/`delivery_requests` never expire a `searching` row on their
  /// own — nothing server-side ever marks it failed — so giving up
  /// client-side (timeout or manual cancel) previously only hid the order
  /// locally while it stayed `searching` forever in the DB, still fully
  /// matchable by a delayed driver push. `update-order-status` now allows
  /// `searching -> cancelled_by_client`; call it so the row actually stops
  /// being live. Best-effort: the local UI gives up on this order either
  /// way, so a network failure here shouldn't block that.
  Future<void> _cancelActiveOrderOnServer() async {
    final orderId = state.activeOrderId;
    if (orderId == null) return;
    final orderType = state.flowType == ClientFlowType.taxi ? 'ride' : 'delivery_request';
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': orderType, 'order_id': orderId, 'next_status': 'cancelled_by_client'},
      );
    } catch (_) {
      // Non-fatal — see doc comment above.
    }
  }

  void cancelSearch() {
    _searchTimeoutTimer?.cancel();
    _orderSub?.cancel();
    unawaited(_cancelActiveOrderOnServer());
    state = state.copyWith(activeOrderId: null, activeOrderStatus: null);
    // `startSearch()` reached this screen via `goTo(ClientScreen.searching)`,
    // which already pushed the confirm screen onto history — using `goTo`
    // here too would push *searching* back on top of it, so the confirm
    // screen's own back button would pop straight back into searching
    // instead of leaving the flow (an infinite loop the user could only
    // escape by force-closing the app). `back()` is the correct inverse of
    // that original `goTo`.
    back();
  }

  /// `table` is `rides` or `delivery_requests`; `orderType` is the matching
  /// string `respond-to-order`/`get_order_counterpart` expect (`ride` /
  /// `delivery_request`). Auto-navigates as the provider's own app advances
  /// the row's status — the client never polls, it just reacts.
  void _subscribeOrderTracking(String table, String id, String orderType) {
    _orderSub?.cancel();
    _orderSub = _sb.from(table).stream(primaryKey: ['id']).eq('id', id).listen((rows) {
      if (rows.isEmpty) return;
      final row = rows.first;
      final status = row['status'] as String?;
      if (status == state.activeOrderStatus) return;
      state = state.copyWith(activeOrderStatus: status);

      if (status == 'accepted' && state.screen == ClientScreen.searching) {
        _searchTimeoutTimer?.cancel();
        final providerId = (row['driver_id'] ?? row['livreur_id']) as String?;
        state = state.copyWith(providerId: providerId);
        unawaited(_fetchProviderContact(orderType, id));
        _subscribeDriverLocation(orderType, id);
        goTo(ClientScreen.providerFound);
      } else if (status == 'completed' &&
          (state.screen == ClientScreen.providerFound || state.screen == ClientScreen.tracking)) {
        state = state.copyWith(
          orderDistanceKm: (row['distance_km'] as num?)?.toDouble() ?? state.orderDistanceKm,
          orderDurationMin: (row['duration_min'] as num?)?.toDouble() ?? state.orderDurationMin,
          orderPrice: (row['price'] as num?)?.toDouble() ?? state.orderPrice,
        );
        _unsubscribeDriverLocation();
        goTo(ClientScreen.tripEnd);
      } else if ((status == 'cancelled_by_driver' || status == 'cancelled_by_client') &&
          state.screen != ClientScreen.home) {
        _unsubscribeDriverLocation();
        goTo(ClientScreen.home);
      }
    });
  }

  Future<void> _fetchProviderContact(String orderType, String orderId) async {
    try {
      final res = await _sb.rpc('get_order_counterpart', params: {'p_order_type': orderType, 'p_order_id': orderId});
      if (res is Map) {
        final vehicleParts = [res['vehicle_name'], res['car_type'], res['vehicle_plate']]
            .whereType<String>()
            .where((s) => s.isNotEmpty);
        state = state.copyWith(
          providerName: res['full_name'] as String?,
          providerPhone: res['phone'] as String?,
          providerVehicle: vehicleParts.isEmpty ? null : vehicleParts.join(' · '),
        );
      }
    } catch (_) {
      // Display-only — screens fall back to a generic placeholder.
    }
  }

  /// Cancelling after a driver/livreur has already accepted (the "إلغاء"
  /// button on the provider-found screen) is a real `update-order-status`
  /// call, not just a local screen jump — `accepted`/`driver_arriving` ->
  /// `cancelled_by_client` is a client-allowed transition in that
  /// function's state machine.
  Future<void> cancelActiveOrder() async {
    final orderId = state.activeOrderId;
    if (orderId == null) {
      goTo(ClientScreen.home);
      return;
    }
    final orderType = state.flowType == ClientFlowType.taxi ? 'ride' : 'delivery_request';
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': orderType, 'order_id': orderId, 'next_status': 'cancelled_by_client'},
      );
    } catch (e) {
      // Must not clear local state or navigate away on failure — the order
      // is still live server-side (e.g. the driver already advanced past
      // a cancellable status), so pretending it was cancelled would leave
      // the client thinking they're done while the driver keeps heading
      // to pickup with no way for either side to find out.
      state = state.copyWith(requestError: _functionErrorMessage(e));
      return;
    }
    _orderSub?.cancel();
    _unsubscribeDriverLocation();
    goTo(ClientScreen.home, patch: (s) => s.copyWith(activeOrderId: null, activeOrderStatus: null));
  }

  void payCashDone() => goTo(ClientScreen.tripRating);

  void rate(int stars) => state = state.copyWith(ratingStars: stars);

  Future<void> finishRating({String? comment}) async {
    final orderId = state.activeOrderId;
    final providerId = state.providerId;
    final uid = _sb.auth.currentUser?.id;
    if (orderId != null && providerId != null && uid != null && state.ratingStars > 0) {
      try {
        await _sb.from('ratings').insert({
          'order_id': orderId,
          'order_type': state.flowType == ClientFlowType.taxi ? 'ride' : 'delivery_request',
          'rated_by': uid,
          'rated_entity_type': state.flowType == ClientFlowType.taxi ? 'driver' : 'livreur',
          'rated_entity_id': providerId,
          'rating': state.ratingStars,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        });
      } catch (_) {
        // Non-fatal — the trip is already over either way.
      }
    }
    _orderSub?.cancel();
    goTo(
      ClientScreen.home,
      patch: (s) => s.copyWith(
        ratingStars: 0,
        activeOrderId: null,
        activeOrderStatus: null,
        providerId: null,
        providerName: null,
        providerPhone: null,
        providerVehicle: null,
        paymentMethod: 'cash',
        orderNote: '',
        pickupLat: null,
        pickupLng: null,
        pickupAddress: null,
        pickupIsUserSet: false,
        dropoffLat: null,
        dropoffLng: null,
        dropoffAddress: null,
        rideDest: '',
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Food — real `restaurants`/`restaurant_dishes` reads,
  // `request-food-order`, Realtime tracking, rating inserts
  // ---------------------------------------------------------------------
  Future<void> goToFoodList() async {
    goTo(ClientScreen.foodList);
    await loadRestaurants();
  }

  /// `nearby_restaurants` (see migration `20260802160001`) returns every
  /// verified restaurant (open or not — the food list screen's own
  /// open/closed filter chips need both) with a real `avg_rating` and a
  /// real PostGIS `distance_km` from the placeholder pickup point, so the
  /// screen's rating/nearest/price/open sort options all have real data to
  /// sort by instead of being decorative.
  Future<void> loadRestaurants() async {
    state = state.copyWith(restaurantsLoading: true);
    try {
      final rows = await _sb.rpc('nearby_restaurants', params: {'p_lat': _placeholderPickup['lat'], 'p_lng': _placeholderPickup['lng']});
      state = state.copyWith(restaurants: List<Map<String, dynamic>>.from(rows as List), restaurantsLoading: false);
    } catch (_) {
      state = state.copyWith(restaurantsLoading: false);
    }
  }

  void setRestaurantSearch(String v) => state = state.copyWith(restaurantSearch: v);
  void setRestaurantFilter(String v) => state = state.copyWith(restaurantFilter: v);

  Future<void> openRestaurant(String id, String name) async {
    goTo(ClientScreen.restaurantDetail, patch: (s) => s.copyWith(selectedRestaurantId: id, selectedRestaurantName: name, cart: const []));
    try {
      final rows = await _sb
          .from('restaurant_dishes')
          .select()
          .eq('restaurant_id', id)
          .eq('is_available', true)
          .eq('available_for_delivery', true);
      state = state.copyWith(restaurantDishes: List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      state = state.copyWith(restaurantDishes: const []);
    }
  }

  void openDish(Map<String, dynamic> dish) => goTo(ClientScreen.dishDetail, patch: (s) => s.copyWith(selectedDish: dish, dishQty: 1));

  void setDishQty(int qty) => state = state.copyWith(dishQty: max(1, qty));

  void addSelectedDishToCart() {
    final dish = state.selectedDish;
    if (dish == null) return;
    addToCart(dish['id'] as String, dish['name'] as String, ((dish['price'] as num).toInt()), state.dishQty);
    goTo(ClientScreen.restaurantDetail);
  }

  void addToCart(String dishId, String name, int price, int qty) {
    final cart = [...state.cart];
    final idx = cart.indexWhere((i) => i.dishId == dishId);
    if (idx >= 0) {
      cart[idx] = cart[idx].copyWith(qty: cart[idx].qty + qty);
    } else {
      cart.add(CartItem(dishId: dishId, name: name, price: price, qty: qty));
    }
    state = state.copyWith(cart: cart);
  }

  void incCartQty(int i) {
    final cart = [...state.cart];
    cart[i] = cart[i].copyWith(qty: cart[i].qty + 1);
    state = state.copyWith(cart: cart);
  }

  void decCartQty(int i) {
    final cart = [...state.cart];
    if (cart[i].qty <= 1) {
      cart.removeAt(i);
    } else {
      cart[i] = cart[i].copyWith(qty: cart[i].qty - 1);
    }
    state = state.copyWith(cart: cart);
  }

  Future<void> placeFoodOrder() async {
    final restaurantId = state.selectedRestaurantId;
    if (restaurantId == null || state.cart.isEmpty) return;
    goTo(ClientScreen.foodWaiting);
    state = state.copyWith(requestError: null);
    try {
      final res = await _sb.functions.invoke('request-food-order', body: {
        'restaurant_id': restaurantId,
        'items': [for (final item in state.cart) {'dish_id': item.dishId, 'qty': item.qty}],
        'delivery_address': state.dropoffAddress ?? 'عنوان التوصيل الافتراضي',
        'delivery_location': {
          'lat': state.dropoffLat ?? state.currentLat ?? _placeholderDropoff['lat']!,
          'lng': state.dropoffLng ?? state.currentLng ?? _placeholderDropoff['lng']!,
        },
        'payment_method': state.paymentMethod,
        if (state.orderNote.trim().isNotEmpty) 'client_note': state.orderNote.trim(),
      });
      final data = res.data as Map;
      state = state.copyWith(
        foodOrderId: data['order_id'] as String,
        foodOrderTotal: (data['total'] as num?)?.toDouble(),
        foodStage: FoodStage.waiting,
      );
      _subscribeFoodOrderTracking(data['order_id'] as String);
    } catch (e) {
      state = state.copyWith(requestError: _functionErrorMessage(e));
      goTo(ClientScreen.cart);
    }
  }

  void _subscribeFoodOrderTracking(String orderId) {
    _foodOrderSub?.cancel();
    _foodOrderSub = _sb.from('food_orders').stream(primaryKey: ['id']).eq('id', orderId).listen((rows) {
      if (rows.isEmpty) return;
      final row = rows.first;
      final status = row['status'] as String?;
      final rowLivreurId = row['livreur_id'] as String?;
      if (rowLivreurId != null && rowLivreurId != state.livreurId) {
        state = state.copyWith(livreurId: rowLivreurId);
      }
      if (status == 'rejected_by_restaurant') {
        _foodOrderSub?.cancel();
        goTo(ClientScreen.foodRejected);
        return;
      }
      final stage = _statusToFoodStage(status);
      if (stage == null) return;

      if (stage == FoodStage.delivered) {
        if (state.screen == ClientScreen.foodTracking || state.screen == ClientScreen.foodWaiting) {
          state = state.copyWith(foodStage: stage);
          goTo(ClientScreen.foodRating);
        }
        return;
      }

      final wasWaiting = state.screen == ClientScreen.foodWaiting;
      state = state.copyWith(foodStage: stage);
      if (stage == FoodStage.accepted) unawaited(_fetchFoodOrderContact(orderId));
      if (stage == FoodStage.onway) unawaited(_fetchFoodOrderContact(orderId));
      if (wasWaiting && stage != FoodStage.waiting) goTo(ClientScreen.foodTracking);
    });
  }

  Future<void> _fetchFoodOrderContact(String orderId) async {
    try {
      final res = await _sb.rpc('get_order_counterpart', params: {'p_order_type': 'food_order', 'p_order_id': orderId});
      if (res is Map) {
        state = state.copyWith(
          providerName: (res['livreur_name'] as String?) ?? (res['restaurant_name'] as String?),
          providerPhone: (res['livreur_phone'] as String?) ?? (res['restaurant_phone'] as String?),
        );
      }
    } catch (_) {
      // Display-only.
    }
  }

  void rateRestaurant(int stars) => state = state.copyWith(foodRatingRestaurant: stars);
  void rateDelivery(int stars) => state = state.copyWith(foodRatingDelivery: stars);

  Future<void> finishFoodRating({String? restaurantComment, String? deliveryComment}) async {
    final orderId = state.foodOrderId;
    final restaurantId = state.selectedRestaurantId;
    final uid = _sb.auth.currentUser?.id;
    if (orderId != null && uid != null) {
      if (restaurantId != null && state.foodRatingRestaurant > 0) {
        try {
          await _sb.from('ratings').insert({
            'order_id': orderId,
            'order_type': 'food_order',
            'rated_by': uid,
            'rated_entity_type': 'restaurant',
            'rated_entity_id': restaurantId,
            'rating': state.foodRatingRestaurant,
            if (restaurantComment != null && restaurantComment.trim().isNotEmpty) 'comment': restaurantComment.trim(),
          });
        } catch (_) {
          // Non-fatal.
        }
      }
      final livreurId = state.livreurId;
      if (livreurId != null && state.foodRatingDelivery > 0) {
        try {
          await _sb.from('ratings').insert({
            'order_id': orderId,
            'order_type': 'food_order',
            'rated_by': uid,
            'rated_entity_type': 'livreur',
            'rated_entity_id': livreurId,
            'rating': state.foodRatingDelivery,
            if (deliveryComment != null && deliveryComment.trim().isNotEmpty) 'comment': deliveryComment.trim(),
          });
        } catch (_) {
          // Non-fatal.
        }
      }
    }
    _foodOrderSub?.cancel();
    goTo(
      ClientScreen.home,
      patch: (s) => s.copyWith(
        foodRatingRestaurant: 0,
        foodRatingDelivery: 0,
        cart: const [],
        foodStage: FoodStage.waiting,
        foodOrderId: null,
        foodOrderTotal: null,
        selectedRestaurantId: null,
        selectedRestaurantName: null,
        restaurantDishes: const [],
        providerName: null,
        providerPhone: null,
        livreurId: null,
        paymentMethod: 'cash',
        orderNote: '',
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Parcel
  // ---------------------------------------------------------------------
  void setParcelType(String v) => state = state.copyWith(parcelType: v);
  void togglePhoto() => state = state.copyWith(parcelPhoto: !state.parcelPhoto);

  // ---------------------------------------------------------------------
  // Voice — UI-only (see class doc comment for why)
  // ---------------------------------------------------------------------
  void toggleRecording() {
    if (state.voiceStage != VoiceStage.recording) {
      state = state.copyWith(voiceStage: VoiceStage.recording);
      return;
    }
    goTo(ClientScreen.voiceAnalyzing);
    _voiceTimer?.cancel();
    _voiceTimer = Timer(const Duration(milliseconds: 1800), () {
      if (state.screen == ClientScreen.voiceAnalyzing) {
        goTo(ClientScreen.voiceConfirm, patch: (s) => s.copyWith(voiceStage: VoiceStage.idle));
      }
    });
  }

  // ---------------------------------------------------------------------
  // Order history / settings
  // ---------------------------------------------------------------------
  void setOrderTab(OrderTab tab) => state = state.copyWith(orderTab: tab);
  void toggleNotif() => state = state.copyWith(notifEnabled: !state.notifEnabled);

  /// Persists to `profiles.language_pref` for real, but this app's own UI
  /// stays Arabic-only regardless (every screen's ~2000 strings are
  /// hardcoded Arabic literals, not routed through `AppLocalizations` — see
  /// `apps/afrigo_client/README.md`); the value is recorded so a future
  /// localization pass has a real signal to read instead of a demo-only
  /// toggle.
  Future<void> setSettingsLang(String lang) async {
    state = state.copyWith(settingsLang: lang);
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _sb.from('profiles').update({'language_pref': lang}).eq('id', uid);
    } catch (_) {
      // Non-fatal — purely a preference record.
    }
  }

  /// Replaces the design's hardcoded "سارة بن علي" demo profile with the
  /// logged-in user's real `profiles` row.
  Future<void> loadProfile() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    state = state.copyWith(profileLoading: true);
    try {
      final row = await _sb.from('profiles').select('full_name, email, phone').eq('id', uid).maybeSingle();
      state = state.copyWith(
        profileFullName: row?['full_name'] as String?,
        profileEmail: (row?['email'] as String?) ?? _sb.auth.currentUser?.email,
        profilePhone: row?['phone'] as String?,
        profileLoading: false,
      );
    } catch (_) {
      state = state.copyWith(profileLoading: false);
    }
  }

  Future<bool> updateFullName(String name) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null || name.trim().isEmpty) return false;
    try {
      await _sb.from('profiles').update({'full_name': name.trim()}).eq('id', uid);
      state = state.copyWith(profileFullName: name.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (newPassword.length < 6) return false;
    try {
      await _sb.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(notificationsLoading: true);
    try {
      final rows = await _sb.from('notifications').select().order('created_at', ascending: false).limit(50);
      state = state.copyWith(notifications: List<Map<String, dynamic>>.from(rows), notificationsLoading: false);
    } catch (_) {
      state = state.copyWith(notificationsLoading: false);
    }
  }

  Future<void> markNotificationRead(String id) async {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications) if (n['id'] == id) {...n, 'is_read': true} else n,
      ],
    );
    try {
      await _sb.from('notifications').update({'is_read': true}).eq('id', id);
    } catch (_) {
      // Non-fatal — local state already reflects the tap either way.
    }
  }

  /// Real past orders merged from the 3 order tables (RLS already scopes
  /// each to `client_id = auth.uid()`) — replaces the design's static demo
  /// order history list.
  Future<void> loadOrderHistory() async {
    if (_sb.auth.currentUser == null) return;
    state = state.copyWith(orderHistoryLoading: true);
    try {
      final results = await Future.wait([
        _sb.from('rides').select('id, status, price, dropoff_address, created_at').order('created_at', ascending: false).limit(30),
        _sb
            .from('food_orders')
            .select('id, status, total, created_at, restaurants(name)')
            .order('created_at', ascending: false)
            .limit(30),
        _sb
            .from('delivery_requests')
            .select('id, status, price, dropoff_address, created_at')
            .order('created_at', ascending: false)
            .limit(30),
      ]);
      final merged = <Map<String, dynamic>>[
        for (final r in results[0]) {'order_type': 'ride', ...r},
        for (final r in results[1]) {'order_type': 'food_order', ...r},
        for (final r in results[2]) {'order_type': 'delivery_request', ...r},
      ]..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
      state = state.copyWith(orderHistory: merged, orderHistoryLoading: false);
    } catch (_) {
      state = state.copyWith(orderHistoryLoading: false);
    }
  }

  Future<void> loadSavedAddresses() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    state = state.copyWith(savedAddressesLoading: true);
    try {
      final rows = await _sb.from('saved_addresses').select('id, label, address').eq('client_id', uid);
      state = state.copyWith(savedAddresses: List<Map<String, dynamic>>.from(rows), savedAddressesLoading: false);
    } catch (_) {
      state = state.copyWith(savedAddressesLoading: false);
    }
  }

  /// Same placeholder-coordinate approach used everywhere else in this app
  /// (see the class doc comment) — a real map picker would replace this
  /// with the point the user actually tapped.
  Future<void> addSavedAddress(String label, String address) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null || address.trim().isEmpty) return;
    try {
      await _sb.from('saved_addresses').insert({
        'client_id': uid,
        'label': label,
        'address': address.trim(),
        'location': 'POINT(${_placeholderDropoff['lng']} ${_placeholderDropoff['lat']})',
      });
      await loadSavedAddresses();
    } catch (_) {
      // Non-fatal — the Settings screen just won't show the new address.
    }
  }

  Future<void> deleteSavedAddress(String id) async {
    state = state.copyWith(savedAddresses: state.savedAddresses.where((a) => a['id'] != id).toList());
    try {
      await _sb.from('saved_addresses').delete().eq('id', id);
    } catch (_) {
      // Non-fatal — worst case it reappears on the next loadSavedAddresses().
    }
  }

  /// `delete-account` (service-role) refuses while an order is still in
  /// flight and otherwise deletes the `auth.users` row outright —
  /// `profiles`/`wallets`/`saved_addresses`/etc. all cascade from it. The
  /// local session is invalid the moment that succeeds, so this also signs
  /// out locally rather than leaving a dangling session.
  ///
  /// Returns the error message on failure (null on success) instead of a
  /// plain bool — `AppRoot`'s global listener reads and clears
  /// `state.requestError` synchronously the instant it's set, so a caller
  /// that re-reads it after this `await` returns always finds it already
  /// `null`. Returning the message directly lets the confirm dialog show the
  /// real reason instead of a generic fallback.
  Future<String?> deleteAccount() async {
    try {
      await _sb.functions.invoke('delete-account');
    } catch (e) {
      final message = _functionErrorMessage(e);
      state = state.copyWith(requestError: message);
      return message;
    }
    await _orderSub?.cancel();
    await _foodOrderSub?.cancel();
    try {
      await _sb.auth.signOut();
    } catch (_) {
      // Best-effort — the server-side account is already gone either way.
    }
    state = const ClientFlowState();
    return null;
  }
}
