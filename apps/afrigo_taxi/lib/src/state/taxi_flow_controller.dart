import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/push_notifications.dart';
import 'taxi_flow_state.dart';
import 'taxi_screen.dart';

final taxiFlowControllerProvider = StateNotifierProvider<TaxiFlowController, TaxiFlowState>(
  (ref) => TaxiFlowController(),
);

/// Ports the original design prototype's `Component` class: same screen/
/// history stack, same field names. Auth, vehicle-doc submission, wallet
/// watch, and now the full ride flow (online toggle, incoming offers,
/// accept/reject, status progression, rating) all call real Supabase —
/// Auth, RLS-scoped reads, and the Section 2 Edge Functions
/// (`toggle-online-status`, `respond-to-order`, `update-order-status`).
class TaxiFlowController extends StateNotifier<TaxiFlowState> {
  TaxiFlowController() : super(const TaxiFlowState()) {
    // The reliable path to the accept/reject sheet — see
    // `PushNotifications`'s doc comment. Listens for the app's whole
    // lifetime, not just while logged in, since a push can arrive/be
    // tapped before `doLogin`'s subscriptions are set up.
    _rideOfferSub = PushNotifications.rideOfferRideIds.listen(showIncomingRideById);
  }

  StreamSubscription<List<Map<String, dynamic>>>? _vehicleSub;
  StreamSubscription<List<Map<String, dynamic>>>? _walletSub;
  StreamSubscription<List<Map<String, dynamic>>>? _commissionSub;
  StreamSubscription<String>? _rideOfferSub;
  RealtimeChannel? _incomingChannel;
  Timer? _incomingTimer;
  RealtimeChannel? _locationChannel;
  Timer? _locationTimer;
  Timer? _onlineLocationTimer;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void dispose() {
    _vehicleSub?.cancel();
    _walletSub?.cancel();
    _commissionSub?.cancel();
    _rideOfferSub?.cancel();
    _incomingTimer?.cancel();
    if (_incomingChannel != null) _sb.removeChannel(_incomingChannel!);
    _stopBroadcastingLocation();
    _onlineLocationTimer?.cancel();
    super.dispose();
  }

  void goTo(TaxiScreen screen, {TaxiFlowState Function(TaxiFlowState)? patch}) {
    final withHist = state.copyWith(hist: [...state.hist, state.screen]);
    state = patch != null ? patch(withHist).copyWith(screen: screen) : withHist.copyWith(screen: screen);
  }

  void back() {
    final hist = [...state.hist];
    final prev = hist.isNotEmpty ? hist.removeLast() : TaxiScreen.home;
    state = state.copyWith(screen: prev, hist: hist);
  }

  void clearActionError() => state = state.copyWith(actionError: null);

  /// `FunctionException.details` is the parsed JSON error body
  /// (`{"error": "..."}`) whenever the Edge Function returned one — see
  /// `_shared/handler.ts`. Falls back to a generic Arabic message otherwise
  /// (network failure, non-JSON 5xx from the platform itself).
  String _functionErrorMessage(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) return details['error'] as String;
    }
    return 'حدث خطأ، حاول مجددًا';
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setConfirmPassword(String v) => state = state.copyWith(confirmPassword: v);
  void setFullName(String v) => state = state.copyWith(fullName: v);

  Future<void> doLogin() async {
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      await _sb.auth.signInWithPassword(email: state.email.trim(), password: state.password);
      state = state.copyWith(isSubmitting: false);
      unawaited(_ensureProfile());
      ensureLiveSubscriptions();
      unawaited(PushNotifications.register());
      unawaited(loadTripHistory());
      unawaited(loadNotifications());
      await _routeAfterAuth();
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تسجيل الدخول، حاول مجددًا');
    }
  }

  /// Splash's "متابعة" used to always go to the login screen, even with a
  /// persisted Supabase session — forcing a full re-login on every process
  /// restart. If a session already exists, skip straight to the same
  /// post-auth routing `doLogin()` uses instead.
  Future<void> continueFromSplash() async {
    if (_sb.auth.currentSession != null) {
      unawaited(_ensureProfile());
      ensureLiveSubscriptions();
      unawaited(PushNotifications.register());
      unawaited(loadTripHistory());
      unawaited(loadNotifications());
      await _routeAfterAuth();
    } else {
      goTo(TaxiScreen.login);
    }
  }

  /// Single source of truth for "where does this driver belong right now",
  /// used by both a fresh login and a resumed session. Previously `doLogin`
  /// always went straight to Home regardless of vehicle status — a pending
  /// or rejected driver who logged out and back in (or just relaunched the
  /// app once session-restore existed) landed on the full Home screen with
  /// no explanation. And nothing anywhere re-attached an in-progress ride
  /// after a restart, so a driver who force-closed mid-ride lost all trace
  /// of owing a client a ride.
  Future<void> _routeAfterAuth() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(TaxiScreen.login);
      return;
    }
    try {
      final vehicle = await _sb
          .from('vehicles')
          .select('status, rejection_reason')
          .eq('owner_id', uid)
          .eq('service_type', 'taxi')
          .maybeSingle();
      if (vehicle == null) {
        goTo(TaxiScreen.vehicleDocs);
        return;
      }
      final status = vehicle['status'] as String?;
      state = state.copyWith(vehicleStatus: status, vehicleRejectionReason: vehicle['rejection_reason'] as String?);
      if (status == 'pending') {
        watchVehicleStatus(uid);
        goTo(TaxiScreen.pendingApproval);
        return;
      }
      if (status == 'rejected') {
        goTo(TaxiScreen.rejected);
        return;
      }
      await _resumeActiveRide();
    } catch (_) {
      goTo(TaxiScreen.home);
    }
  }

  /// Re-attaches an in-progress ride after login/resume so a driver who
  /// force-closed the app mid-ride (crash, OS kill, battery) lands back on
  /// the right screen instead of Home with zero awareness they still owe a
  /// client a ride.
  Future<void> _resumeActiveRide() async {
    try {
      final rows = await _sb
          .from('rides')
          .select()
          .eq('driver_id', _sb.auth.currentUser!.id)
          .inFilter('status', ['accepted', 'driver_arriving', 'in_progress'])
          .order('accepted_at', ascending: false)
          .limit(1);
      if (rows.isEmpty) {
        goTo(TaxiScreen.home);
        return;
      }
      final ride = ActiveRide.fromRow(rows.first);
      state = state.copyWith(activeRide: ride);
      unawaited(_fetchClientContact(ride.id));
      _startBroadcastingLocation(ride.id);
      goTo(ride.status == 'in_progress' ? TaxiScreen.tripOngoing : TaxiScreen.navigateToPickup);
    } catch (_) {
      goTo(TaxiScreen.home);
    }
  }

  Future<void> doSignup() async {
    if (state.password != state.confirmPassword) {
      state = state.copyWith(authError: 'كلمتا المرور غير متطابقتين');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // Only creates the auth.users row — profiles/wallets (role='taxi_driver')
      // are created by `register-provider` once the user confirms via OTP.
      await _sb.auth.signUp(email: state.email.trim(), password: state.password, data: {'full_name': state.fullName});
      state = state.copyWith(isSubmitting: false);
      goTo(TaxiScreen.otp);
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إنشاء الحساب، حاول مجددًا');
    }
  }

  /// The original prototype never validates the OTP either — it just
  /// advances. Wire `auth.verifyOTP(...)` here once an SMS/email OTP
  /// provider is configured on the Supabase project. `register-provider`
  /// creates the `profiles`/`wallets` rows for the now-confirmed user.
  Future<void> confirmOtp() async {
    try {
      await _sb.functions.invoke('register-provider', body: {'role': 'taxi_driver', 'full_name': state.fullName});
    } catch (_) {
      // Non-fatal — vehicleDocs submission below still works even if this
      // races the auth session; register-provider is idempotent.
    }
    goTo(TaxiScreen.accountCreating);
  }

  /// Self-heals accounts stuck with an `auth.users` row but no `profiles`/
  /// `wallets` row — real accounts hit this in testing when the OTP-confirm
  /// step's `register-provider` call raced a network blip and silently
  /// failed. `register-provider` is idempotent (returns immediately if a
  /// profile already exists), so calling it again on every login is cheap
  /// and never overwrites real data.
  Future<void> _ensureProfile() async {
    try {
      final fullName = _sb.auth.currentUser?.userMetadata?['full_name'] as String? ?? '';
      await _sb.functions.invoke('register-provider', body: {'role': 'taxi_driver', 'full_name': fullName.trim().isEmpty ? 'مستخدم' : fullName});
    } catch (_) {
      // Non-fatal — same reasoning as the OTP-confirm call site.
    }
  }

  Future<void> signOut() async {
    await _vehicleSub?.cancel();
    await _walletSub?.cancel();
    await _commissionSub?.cancel();
    _incomingTimer?.cancel();
    if (_incomingChannel != null) {
      await _sb.removeChannel(_incomingChannel!);
      _incomingChannel = null;
    }
    _stopBroadcastingLocation();
    await _sb.auth.signOut();
    state = const TaxiFlowState();
  }

  // ---------------------------------------------------------------------
  // Vehicle verification — real insert + Realtime watch
  // ---------------------------------------------------------------------
  void setLicensePhoto(bool value) => state = state.copyWith(licensePhoto: value);

  /// Was previously just a boolean toggle with no real file behind it —
  /// `submitVehicleDocs` always wrote the literal string 'pending-upload',
  /// so admin review had no actual photo to look at. Uploads to a fixed
  /// path per driver (`{uid}/license.jpg`, upsert) so re-uploading just
  /// replaces the old file rather than accumulating orphans.
  Future<void> pickAndUploadLicense(ImageSource source) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    state = state.copyWith(licenseUploading: true, authError: null);
    try {
      final bytes = await picked.readAsBytes();
      await _sb.storage.from('vehicle-docs').uploadBinary(
            '$uid/license.jpg',
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      state = state.copyWith(licenseUploading: false, licensePhoto: true);
    } catch (_) {
      state = state.copyWith(licenseUploading: false, authError: 'تعذّر رفع الصورة، حاول مجددًا');
    }
  }

  /// Lets `VehicleDocsScreen` pre-fill its fields when opened for an edit
  /// (from Profile) instead of always starting blank — without this,
  /// submitting after only fixing one field (e.g. the plate number)
  /// silently overwrote every other already-approved field with an empty
  /// string, since `submitVehicleDocs` always upserts the full row.
  Future<Map<String, dynamic>?> fetchMyVehicle() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      return await _sb.from('vehicles').select().eq('owner_id', uid).eq('service_type', 'taxi').maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// `ProfileScreen` used to show a hardcoded fake name/rating for every
  /// driver ("مراد بلحاج", "4.8 · 312 رحلة"). Name comes straight from the
  /// auth session (set at signup); rating is averaged from `ratings` rows
  /// where this driver is the rated entity — `ratings_select_involved_or_admin`
  /// (`rated_entity_id = auth.uid()`) already permits a driver to read their
  /// own ratings directly.
  Future<({String name, double avgRating, int ratingCount})> fetchMyProfileSummary() async {
    final uid = _sb.auth.currentUser?.id;
    final name = _sb.auth.currentUser?.userMetadata?['full_name'] as String? ?? 'سائق';
    if (uid == null) return (name: name, avgRating: 0.0, ratingCount: 0);
    try {
      final rows = await _sb.from('ratings').select('rating').eq('rated_entity_id', uid).eq('rated_entity_type', 'driver');
      if (rows.isEmpty) return (name: name, avgRating: 0.0, ratingCount: 0);
      final total = rows.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
      return (name: name, avgRating: total / rows.length, ratingCount: rows.length);
    } catch (_) {
      return (name: name, avgRating: 0.0, ratingCount: 0);
    }
  }

  Future<void> submitVehicleDocs({
    required String vehicleName,
    required String address,
    required String carType,
    required String plateNumber,
    required String notes,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(TaxiScreen.pendingApproval);
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // upsert, not insert — a plain insert let re-submitting (e.g. after a
      // rejection) silently create a second `vehicles` row for the same
      // owner+service_type, which then broke `toggle-online-status`'s
      // `.maybeSingle()` lookup (errors on >1 row, surfaced as "no vehicle
      // linked to this account" even though a verified one existed).
      await _sb.from('vehicles').upsert({
        'owner_id': uid,
        'service_type': 'taxi',
        'vehicle_name': vehicleName,
        'address': address,
        'driving_license_url': state.licensePhoto ? '$uid/license.jpg' : '',
        'car_type': carType,
        'plate_number': plateNumber,
        'notes': notes,
      }, onConflict: 'owner_id,service_type');
      state = state.copyWith(isSubmitting: false);
      watchVehicleStatus(uid);
      goTo(TaxiScreen.pendingApproval);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إرسال بيانات المركبة، حاول مجددًا');
    }
  }

  void watchVehicleStatus(String uid) {
    _vehicleSub?.cancel();
    _vehicleSub = _sb
        .from('vehicles')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .order('created_at')
        .listen((rows) {
      if (rows.isEmpty) return;
      final latest = rows.last;
      final status = latest['status'] as String?;
      state = state.copyWith(
        vehicleStatus: status,
        vehicleRejectionReason: latest['rejection_reason'] as String?,
      );
      if (status == 'rejected' && state.screen == TaxiScreen.pendingApproval) {
        goTo(TaxiScreen.rejected);
      } else if (status == 'verified' && state.screen == TaxiScreen.pendingApproval) {
        goTo(TaxiScreen.home);
      }
    });
  }

  // ---------------------------------------------------------------------
  // Wallet — real read + Realtime watch
  // ---------------------------------------------------------------------
  /// Wires up every Realtime subscription a logged-in driver needs — called
  /// from `doLogin()` on a fresh sign-in, and again from `HomeScreen`'s
  /// `initState` so a session that was already persisted (app relaunched
  /// while still logged in, `doLogin()` never ran this process) still gets
  /// a live incoming-ride channel instead of silently never receiving ride
  /// offers — that gap was a real bug: a driver could be online and
  /// correctly matched by `find_nearby_vehicles`, yet never see the offer
  /// because nothing had ever subscribed `driver:{uid}:incoming_orders`
  /// this session. Safe to call repeatedly — every subscription here
  /// cancels its previous instance first.
  void ensureLiveSubscriptions() {
    if (_sb.auth.currentUser == null) return;
    watchWallet();
    _subscribeIncomingRides();
    _watchCommissionPct();
  }

  void watchWallet() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    _walletSub?.cancel();
    _walletSub = _sb.from('wallets').stream(primaryKey: ['id']).eq('owner_id', uid).listen((rows) {
      if (rows.isEmpty) {
        state = state.copyWith(walletLoaded: true);
        return;
      }
      final balance = (rows.first['balance'] as num?)?.toDouble();
      final walletId = rows.first['id'] as String?;
      state = state.copyWith(balance: balance, walletLoaded: true, walletId: walletId);
      if (walletId != null) loadWalletTransactions();
    });
  }

  /// Real `wallet_transactions` rows for the Wallet screen's "سجل الحركات"
  /// — replaces the 2 hardcoded demo rows there.
  Future<void> loadWalletTransactions() async {
    final walletId = state.walletId;
    if (walletId == null) return;
    state = state.copyWith(walletTransactionsLoading: true);
    try {
      final rows = await _sb.from('wallet_transactions').select().eq('wallet_id', walletId).order('created_at', ascending: false).limit(30);
      state = state.copyWith(walletTransactions: List<Map<String, dynamic>>.from(rows), walletTransactionsLoading: false);
    } catch (_) {
      state = state.copyWith(walletTransactionsLoading: false);
    }
  }

  /// Real `rides` rows for this driver — backs both the Trip History screen
  /// and the Home screen's "رحلات اليوم"/"أرباح اليوم" cards (derived
  /// client-side from the subset completed today), replacing the design's
  /// hardcoded demo trips / fixed 7-trips-2,340-أوقية stat cards.
  Future<void> loadTripHistory() async {
    if (_sb.auth.currentUser == null) return;
    state = state.copyWith(tripHistoryLoading: true);
    try {
      final rows = await _sb.rpc('driver_trip_history', params: {'p_limit': 50}) as List;
      state = state.copyWith(tripHistory: List<Map<String, dynamic>>.from(rows), tripHistoryLoading: false);
    } catch (_) {
      state = state.copyWith(tripHistoryLoading: false);
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

  /// Live watch, not a one-time fetch — the Wallet screen's "نسبة العمولة"
  /// should reflect whatever an admin has it set to *right now* in
  /// `CommissionSettingsPage`, not whatever it was when this driver last
  /// logged in.
  void _watchCommissionPct() {
    _commissionSub?.cancel();
    _commissionSub = _sb.from('commission_settings').stream(primaryKey: ['service_type']).eq('service_type', 'taxi').listen((rows) {
      if (rows.isEmpty) return;
      state = state.copyWith(commissionPct: (rows.first['percentage'] as num).toDouble());
    });
  }

  // ---------------------------------------------------------------------
  // Home / online toggle — real `toggle-online-status`
  // ---------------------------------------------------------------------
  /// Real device GPS fix — the driver's own live position shown on the
  /// home/pickup/trip maps. Fails silently (every caller already falls back
  /// to the placeholder via `currentLat`/`Lng` being null) since a denied
  /// permission or disabled location service shouldn't block anything else
  /// in the app.
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

  /// Broadcasts this driver's live position directly on
  /// `order_location:ride:{rideId}` — the Client app's own controller
  /// subscribes to the same topic the moment it sees the ride go
  /// `accepted`. Sent as a plain Realtime Broadcast (no DB write, no
  /// server round-trip) since nothing needs to persist a full breadcrumb
  /// trail here, just the current position.
  void _startBroadcastingLocation(String rideId) {
    _stopBroadcastingLocation();
    _locationChannel = _sb.channel('order_location:ride:$rideId')..subscribe();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
        state = state.copyWith(currentLat: pos.latitude, currentLng: pos.longitude);
        await _locationChannel?.sendBroadcastMessage(event: 'location', payload: {'lat': pos.latitude, 'lng': pos.longitude});
      } catch (_) {
        // Non-fatal — a missed ping just means the client's marker doesn't
        // move for a beat; the next tick tries again.
      }
    });
  }

  void _stopBroadcastingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
    if (_locationChannel != null) {
      _sb.removeChannel(_locationChannel!);
      _locationChannel = null;
    }
  }

  Future<void> toggleOnline() async {
    if (state.lowBalance) return;
    final target = !state.online;
    try {
      final res = await _sb.functions.invoke('toggle-online-status', body: {'online': target});
      final online = (res.data as Map)['online'] as bool? ?? target;
      state = state.copyWith(online: online);
      if (online) {
        _startOnlineLocationUpdates();
      } else {
        _stopOnlineLocationUpdates();
      }
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  /// Keeps `vehicles.current_location` fresh while online — without this,
  /// `find_nearby_vehicles`'s `ST_DWithin` / `current_location is not null`
  /// filter silently excludes this driver from every search no matter how
  /// verified/online they are (this was a real bug: a verified, online
  /// driver with a null `current_location` never matched a single ride).
  /// Separate from `_startBroadcastingLocation`, which only runs during an
  /// active trip and pushes to a Realtime channel, not the DB — this one
  /// runs the whole time the driver is online, and its job is purely to
  /// keep this driver *findable*.
  void _startOnlineLocationUpdates() {
    _onlineLocationTimer?.cancel();
    _pushOnlineLocation();
    _onlineLocationTimer = Timer.periodic(const Duration(seconds: 15), (_) => _pushOnlineLocation());
  }

  void _stopOnlineLocationUpdates() {
    _onlineLocationTimer?.cancel();
    _onlineLocationTimer = null;
  }

  Future<void> _pushOnlineLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      state = state.copyWith(currentLat: pos.latitude, currentLng: pos.longitude);
      final uid = _sb.auth.currentUser?.id;
      if (uid == null) return;
      await _sb
          .from('vehicles')
          .update({
            'current_location': 'POINT(${pos.longitude} ${pos.latitude})',
            'location_updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('owner_id', uid)
          .eq('service_type', 'taxi');
    } catch (_) {
      // Non-fatal — a missed update just means the next 15s tick retries;
      // the driver simply won't match new searches until one succeeds.
    }
  }

  // ---------------------------------------------------------------------
  // Incoming ride — real Realtime Broadcast + respond-to-order
  // ---------------------------------------------------------------------
  /// `request-ride` broadcasts on this exact topic/event for every matched
  /// driver — see supabase/functions/_shared/broadcast.ts and
  /// supabase/functions/request-ride/index.ts.
  void _subscribeIncomingRides() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    if (_incomingChannel != null) _sb.removeChannel(_incomingChannel!);
    _incomingChannel = _sb.channel('driver:$uid:incoming_orders')
      ..onBroadcast(
        event: 'incoming_ride',
        callback: (payload) => _onIncomingRide(payload),
      )
      ..subscribe();
  }

  void _onIncomingRide(Map<String, dynamic> payload) {
    _showIncomingRideOffer(IncomingRideOffer.fromPayload(payload));
  }

  /// Fetches a ride directly by id and shows the same accept/reject sheet
  /// `_onIncomingRide` shows from a live broadcast — called when a push
  /// notification (tapped, or received while the app is already open)
  /// carries `data: {type: 'incoming_ride', ride_id}`. This is the reliable
  /// path: the Realtime Broadcast channel only works while this driver's
  /// socket happens to be connected at the exact broadcast instant (lost
  /// the moment Android backgrounds the app); a push notification survives
  /// that and this handler turns it into the same real offer, fetched
  /// fresh from `rides` rather than trusting a payload that might be stale
  /// by the time it's tapped.
  Future<void> showIncomingRideById(String rideId) async {
    if (state.activeRide != null || state.incomingRide != null) return;
    try {
      final row = await _sb.from('rides').select().eq('id', rideId).maybeSingle();
      if (row == null || row['status'] != 'searching') return;
      _showIncomingRideOffer(IncomingRideOffer(
        rideId: row['id'] as String,
        pickupAddress: row['pickup_address'] as String? ?? '',
        pickupLat: (row['pickup_lat'] as num?)?.toDouble() ?? 18.0858,
        pickupLng: (row['pickup_lng'] as num?)?.toDouble() ?? -15.9785,
        dropoffAddress: row['dropoff_address'] as String? ?? '',
        dropoffLat: (row['dropoff_lat'] as num?)?.toDouble() ?? 18.0858,
        dropoffLng: (row['dropoff_lng'] as num?)?.toDouble() ?? -15.9785,
        distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0,
        price: (row['price'] as num?)?.toDouble() ?? 0,
      ));
      goTo(TaxiScreen.home);
    } catch (_) {
      // Non-fatal — the ride may have already been taken by another driver
      // between the tap and this fetch; nothing to show either way.
    }
  }

  void _showIncomingRideOffer(IncomingRideOffer offer) {
    // Ignore new offers while a trip is already active or another offer is
    // being shown — this driver is busy either way.
    if (state.activeRide != null || state.incomingRide != null) return;
    state = state.copyWith(incomingRide: offer, incomingCountdown: 20);
    _incomingTimer?.cancel();
    _incomingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.incomingCountdown <= 1) {
        t.cancel();
        state = state.copyWith(incomingRide: null);
        return;
      }
      state = state.copyWith(incomingCountdown: state.incomingCountdown - 1);
    });
  }

  Future<void> acceptIncoming() async {
    final offer = state.incomingRide;
    if (offer == null) return;
    _incomingTimer?.cancel();
    state = state.copyWith(incomingRide: null);
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'ride', 'order_id': offer.rideId, 'decision': 'accept'},
      );
      final row = await _sb.from('rides').select().eq('id', offer.rideId).single();
      final ride = ActiveRide.fromRow(row);
      state = state.copyWith(activeRide: ride);
      unawaited(_fetchClientContact(offer.rideId));
      _startBroadcastingLocation(ride.id);
      goTo(TaxiScreen.navigateToPickup);
    } catch (e) {
      // Most common cause: another driver accepted first (409) — stay on
      // the home screen, the offer is simply gone now.
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  Future<void> rejectIncoming() async {
    final offer = state.incomingRide;
    _incomingTimer?.cancel();
    state = state.copyWith(incomingRide: null);
    if (offer == null) return;
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'ride', 'order_id': offer.rideId, 'decision': 'reject'},
      );
    } catch (_) {
      // Reject is a no-op server-side (see respond-to-order) — nothing to
      // recover from; the offer is already hidden locally.
    }
  }

  Future<void> _fetchClientContact(String rideId) async {
    try {
      final res = await _sb.rpc('get_order_counterpart', params: {'p_order_type': 'ride', 'p_order_id': rideId});
      if (res is Map) {
        state = state.copyWith(clientName: res['full_name'] as String?, clientPhone: res['phone'] as String?);
      }
    } catch (_) {
      // Display-only — screens fall back to a generic placeholder.
    }
  }

  // ---------------------------------------------------------------------
  // Trip flow — real `update-order-status`
  // ---------------------------------------------------------------------
  /// Returns whether the transition actually succeeded server-side — a
  /// caller must never navigate forward on failure, or the driver's screen
  /// silently disagrees with the real order state (this exact gap is what
  /// let a failed "end trip" call still walk the driver through to the
  /// rating screen while the ride stayed `in_progress` in the DB forever).
  Future<bool> _advanceRide(String nextStatus) async {
    final ride = state.activeRide;
    if (ride == null) return false;
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': 'ride', 'order_id': ride.id, 'next_status': nextStatus},
      );
      state = state.copyWith(activeRide: ride.copyWith(status: nextStatus));
      return true;
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
      return false;
    }
  }

  /// Screen 55's single "وصلت / بدء الرحلة" button covers both the
  /// `driver_arriving` and `in_progress` steps of the state machine — there
  /// is no separate "confirm arrival" tap in this design, so this makes
  /// both transitions back to back rather than skipping a required step.
  ///
  /// Skips the first transition if the ride is already `driver_arriving` —
  /// without this, a driver retrying after the first call succeeded but the
  /// second one failed (network blip) would resend `driver_arriving` from
  /// `driver_arriving`, which the server correctly rejects as an invalid
  /// transition, permanently stranding them with no way to proceed.
  Future<void> startTripOngoing() async {
    if (state.activeRide?.status != 'driver_arriving') {
      if (!await _advanceRide('driver_arriving')) return;
    }
    if (!await _advanceRide('in_progress')) return;
    goTo(TaxiScreen.tripOngoing);
  }

  /// Only valid while the ride hasn't started yet (`accepted`/
  /// `driver_arriving` — enforced server-side too); once `in_progress`
  /// there is no cancel, only completing the trip.
  Future<void> cancelRide() async {
    final ride = state.activeRide;
    if (ride == null) return;
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': 'ride', 'order_id': ride.id, 'next_status': 'cancelled_by_driver'},
      );
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
      return;
    }
    _stopBroadcastingLocation();
    state = state.copyWith(activeRide: null, clientName: null, clientPhone: null);
    goTo(TaxiScreen.home);
  }

  Future<void> endTripDriver() async {
    if (!await _advanceRide('completed')) return;
    _stopBroadcastingLocation();
    goTo(TaxiScreen.tripEndSummary);
  }

  void payReceivedCash() => goTo(TaxiScreen.rateCustomer);

  void rateCustomer(int stars) => state = state.copyWith(custRating: stars);

  Future<void> finishRateCustomer({String? comment}) async {
    final ride = state.activeRide;
    final uid = _sb.auth.currentUser?.id;
    if (ride != null && uid != null && state.custRating > 0) {
      try {
        await _sb.from('ratings').insert({
          'order_id': ride.id,
          'order_type': 'ride',
          'rated_by': uid,
          'rated_entity_type': 'client',
          'rated_entity_id': ride.clientId,
          'rating': state.custRating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        });
      } catch (_) {
        // Non-fatal — the trip is already completed and paid; a failed
        // rating insert shouldn't block the driver from going back online.
      }
    }
    goTo(
      TaxiScreen.home,
      patch: (s) => s.copyWith(custRating: 0, activeRide: null, clientName: null, clientPhone: null),
    );
    unawaited(loadTripHistory());
  }
}
