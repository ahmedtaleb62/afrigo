import 'dart:async';

import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/push_notifications.dart';
import 'livreur_flow_state.dart';
import 'livreur_screen.dart';

final livreurFlowControllerProvider = StateNotifierProvider<LivreurFlowController, LivreurFlowState>(
  (ref) => LivreurFlowController(),
);

/// Ports the original design prototype's `Component` class — structurally
/// near-identical to `afrigo_taxi`'s controller (one vehicle to verify, one
/// wallet, one online switch, one incoming-request flow), with one added
/// wrinkle: a livreur receives offers from TWO sources on the same Realtime
/// channel — standalone parcels (`delivery_requests`, event
/// `incoming_delivery`) and the second leg of a food order (`food_orders`
/// reaching `ready`, event `incoming_food_delivery`) — see
/// `DeliveryOrderType`. Real pieces: auth, vehicle-doc submission +
/// Realtime status watch, wallet watch, and now the full delivery flow
/// (online toggle, incoming offers, accept/reject, status progression,
/// rating) via `toggle-online-status` / `respond-to-order` /
/// `update-order-status`.
class LivreurFlowController extends StateNotifier<LivreurFlowState> {
  LivreurFlowController() : super(const LivreurFlowState());

  StreamSubscription<List<Map<String, dynamic>>>? _vehicleSub;
  StreamSubscription<List<Map<String, dynamic>>>? _walletSub;
  RealtimeChannel? _incomingChannel;
  Timer? _incomingTimer;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void dispose() {
    _vehicleSub?.cancel();
    _walletSub?.cancel();
    _incomingTimer?.cancel();
    if (_incomingChannel != null) _sb.removeChannel(_incomingChannel!);
    super.dispose();
  }

  void goTo(LivreurScreen screen, {LivreurFlowState Function(LivreurFlowState)? patch}) {
    final withHist = state.copyWith(hist: [...state.hist, state.screen]);
    state = patch != null ? patch(withHist).copyWith(screen: screen) : withHist.copyWith(screen: screen);
  }

  void back() {
    final hist = [...state.hist];
    final prev = hist.isNotEmpty ? hist.removeLast() : LivreurScreen.home;
    state = state.copyWith(screen: prev, hist: hist);
  }

  void clearActionError() => state = state.copyWith(actionError: null);

  String _functionErrorMessage(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) return details['error'] as String;
    }
    return 'حدث خطأ، حاول مجددًا';
  }

  // ---------------------------------------------------------------------
  // Auth — real Supabase calls. Phone-first: signup/login identify the
  // account by Mauritanian mobile number (Chinguisoft SMS OTP via the
  // `sms-hook` Auth Hook Edge Function), not email — mirrors
  // `afrigo_client`'s `ClientFlowController`.
  // ---------------------------------------------------------------------
  /// Mauritanian mobile numbers are 8 digits starting with 2, 3, or 4 (the
  /// same shape Chinguisoft's API requires) — `null` when `local` doesn't
  /// match, so every call site can treat that as "invalid, don't submit".
  String? _toE164(String local) {
    final trimmed = local.trim();
    if (!RegExp(r'^[234]\d{7}$').hasMatch(trimmed)) return null;
    return '+222$trimmed';
  }

  void setPhone(String v) => state = state.copyWith(phone: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setConfirmPassword(String v) => state = state.copyWith(confirmPassword: v);
  void setFullName(String v) => state = state.copyWith(fullName: v);

  Future<void> doLogin() async {
    final e164 = _toE164(state.phone);
    if (e164 == null || state.password.isEmpty) {
      state = state.copyWith(authError: 'أدخل رقم هاتف موريتاني صحيح (8 أرقام) وكلمة المرور');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      await _sb.auth.signInWithPassword(phone: e164, password: state.password);
      state = state.copyWith(isSubmitting: false);
      unawaited(_ensureProfile());
      watchWallet();
      _subscribeIncomingDeliveries();
      unawaited(PushNotifications.register());
      goTo(LivreurScreen.home);
    } on AuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        authError: friendlyAuthError(code: e.code, message: e.message, fallback: 'تعذّر تسجيل الدخول، حاول مجددًا'),
      );
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تسجيل الدخول، حاول مجددًا');
    }
  }

  Future<void> doSignup() async {
    final e164 = _toE164(state.phone);
    if (e164 == null) {
      state = state.copyWith(authError: 'أدخل رقم هاتف موريتاني صحيح (8 أرقام)');
      return;
    }
    if (state.password != state.confirmPassword) {
      state = state.copyWith(authError: 'كلمتا المرور غير متطابقتين');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // Only creates the auth.users row (unconfirmed until the OTP screen's
      // `confirmOtp()` verifies the SMS code) — profiles/wallets
      // (role='livreur') are created by `register-provider` once the user
      // confirms via OTP.
      await _sb.auth.signUp(phone: e164, password: state.password, data: {'full_name': state.fullName});
      state = state.copyWith(isSubmitting: false, otp: const ['', '', '', '', '', ''], otpCountdown: 45);
      goTo(LivreurScreen.otp);
    } on AuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        authError: friendlyAuthError(code: e.code, message: e.message, fallback: 'تعذّر إنشاء الحساب، حاول مجددًا'),
      );
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إنشاء الحساب، حاول مجددًا');
    }
  }

  void setOtpDigit(int index, String value) {
    final otp = [...state.otp];
    otp[index] = value;
    state = state.copyWith(otp: otp);
  }

  /// Real verification via Supabase Auth's phone OTP (`sms_otp_length: 6`,
  /// delivered by Chinguisoft through the `sms-hook` Auth Hook) — a wrong or
  /// expired code throws an `AuthException` here, surfaced via
  /// `friendlyAuthError`. `register-provider` (role: 'livreur') still runs
  /// right after, same as before, to create the `profiles`/`wallets` rows.
  Future<void> confirmOtp() async {
    final e164 = _toE164(state.phone);
    final code = state.otp.join();
    if (e164 == null || code.length < 6) {
      state = state.copyWith(authError: 'أدخل الرمز المكوّن من 6 أرقام');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      await _sb.auth.verifyOTP(phone: e164, token: code, type: OtpType.sms);
    } on AuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        authError: friendlyAuthError(code: e.code, message: e.message, fallback: 'رمز غير صحيح أو منتهي الصلاحية'),
      );
      return;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تأكيد الرمز، حاول مجددًا');
      return;
    }
    try {
      await _sb.functions.invoke('register-provider', body: {'role': 'livreur', 'full_name': state.fullName});
    } catch (_) {
      // Non-fatal — vehicleDocs submission below still works even if this
      // races the auth session; register-provider is idempotent.
    }
    state = state.copyWith(isSubmitting: false);
    goTo(LivreurScreen.vehicleDocs);
  }

  /// Countdown-gated resend — `signInWithOtp` on an unconfirmed phone
  /// re-triggers the same signup OTP flow (GoTrue treats it as a resend),
  /// hitting the `sms-hook` again for a fresh Chinguisoft SMS.
  Future<void> resendOtp() async {
    final e164 = _toE164(state.phone);
    if (e164 == null) return;
    try {
      await _sb.auth.signInWithOtp(phone: e164);
      state = state.copyWith(otp: const ['', '', '', '', '', ''], otpCountdown: 45, authError: null);
    } catch (_) {
      state = state.copyWith(authError: 'تعذّر إعادة إرسال الرمز، حاول مجددًا');
    }
  }

  /// Self-heals accounts stuck with an `auth.users` row but no `profiles`/
  /// `wallets` row — safe to call on every login since `register-provider`
  /// is idempotent (returns immediately if a profile already exists).
  Future<void> _ensureProfile() async {
    try {
      final fullName = _sb.auth.currentUser?.userMetadata?['full_name'] as String? ?? '';
      await _sb.functions.invoke('register-provider', body: {'role': 'livreur', 'full_name': fullName.trim().isEmpty ? 'مستخدم' : fullName});
    } catch (_) {
      // Non-fatal — same reasoning as the OTP-confirm call site.
    }
  }

  Future<void> signOut() async {
    await _vehicleSub?.cancel();
    await _walletSub?.cancel();
    _incomingTimer?.cancel();
    if (_incomingChannel != null) {
      await _sb.removeChannel(_incomingChannel!);
      _incomingChannel = null;
    }
    await _sb.auth.signOut();
    state = const LivreurFlowState();
  }

  // ---------------------------------------------------------------------
  // Vehicle verification — real insert + Realtime watch
  // ---------------------------------------------------------------------
  void toggleLicensePhoto() => state = state.copyWith(licensePhoto: !state.licensePhoto);

  Future<void> submitVehicleDocs({
    required String vehicleName,
    required String address,
    required String bikeType,
    required String plateNumber,
    required String notes,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(LivreurScreen.pendingApproval);
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // upsert, not insert — a plain insert let re-submitting silently
      // create a second `vehicles` row for the same owner+service_type,
      // which then broke `toggle-online-status`'s `.maybeSingle()` lookup
      // (errors on >1 row, surfaced as "no vehicle linked to this account"
      // even though a verified one existed).
      await _sb.from('vehicles').upsert({
        'owner_id': uid,
        'service_type': 'delivery',
        'vehicle_name': vehicleName,
        'address': address,
        'driving_license_url': state.licensePhoto ? 'pending-upload' : '',
        'car_type': bikeType,
        'plate_number': plateNumber,
        'notes': notes,
      }, onConflict: 'owner_id,service_type');
      state = state.copyWith(isSubmitting: false);
      watchVehicleStatus(uid);
      goTo(LivreurScreen.pendingApproval);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إرسال البيانات، حاول مجددًا');
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
      if (status == 'rejected' && state.screen == LivreurScreen.pendingApproval) {
        goTo(LivreurScreen.rejected);
      } else if (status == 'verified' && state.screen == LivreurScreen.pendingApproval) {
        goTo(LivreurScreen.home);
      }
    });
  }

  /// Design-only preview button — the real transition happens automatically
  /// via `watchVehicleStatus` once an admin actually rejects.
  void simulateRejected() => goTo(LivreurScreen.rejected);

  // ---------------------------------------------------------------------
  // Wallet — real read + Realtime watch
  // ---------------------------------------------------------------------
  void watchWallet() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    _walletSub?.cancel();
    _walletSub = _sb.from('wallets').stream(primaryKey: ['id']).eq('owner_id', uid).listen((rows) {
      if (rows.isEmpty) return;
      final balance = (rows.first['balance'] as num?)?.toDouble();
      state = state.copyWith(balance: balance);
    });
  }

  Future<void> _fetchCommissionPct(String serviceType) async {
    try {
      final row =
          await _sb.from('commission_settings').select('percentage').eq('service_type', serviceType).maybeSingle();
      if (row != null) state = state.copyWith(commissionPct: (row['percentage'] as num).toDouble());
    } catch (_) {
      // Display-only.
    }
  }

  // ---------------------------------------------------------------------
  // Home / online toggle — real `toggle-online-status`
  // ---------------------------------------------------------------------
  Future<void> toggleOnline() async {
    if (state.lowBalance) return;
    final target = !state.online;
    try {
      final res = await _sb.functions.invoke('toggle-online-status', body: {'online': target});
      final online = (res.data as Map)['online'] as bool? ?? target;
      state = state.copyWith(online: online);
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  void toggleLowBalanceDemo() => state = state.copyWith(
        lowBalanceDemo: !state.lowBalanceDemo,
        online: state.lowBalanceDemo ? state.online : false,
      );

  // ---------------------------------------------------------------------
  // Incoming delivery — real Realtime Broadcast + respond-to-order
  // ---------------------------------------------------------------------
  /// One channel, two possible events: `request-delivery` broadcasts
  /// `incoming_delivery` for standalone parcels, and `update-order-status`
  /// broadcasts `incoming_food_delivery` when a restaurant marks a food
  /// order `ready` — see supabase/functions/_shared/broadcast.ts and the
  /// two functions above.
  void _subscribeIncomingDeliveries() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    if (_incomingChannel != null) _sb.removeChannel(_incomingChannel!);
    _incomingChannel = _sb.channel('delivery:$uid:incoming_orders')
      ..onBroadcast(event: 'incoming_delivery', callback: (payload) => _onIncomingParcel(payload))
      ..onBroadcast(event: 'incoming_food_delivery', callback: (payload) => _onIncomingFoodLeg(payload))
      ..subscribe();
  }

  void _startOfferCountdown() {
    state = state.copyWith(incomingCountdown: 20);
    _incomingTimer?.cancel();
    _incomingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.incomingCountdown <= 1) {
        t.cancel();
        state = state.copyWith(incomingOffer: null);
        return;
      }
      state = state.copyWith(incomingCountdown: state.incomingCountdown - 1);
    });
  }

  void _onIncomingParcel(Map<String, dynamic> payload) {
    if (state.activeDelivery != null || state.incomingOffer != null) return;
    state = state.copyWith(
      incomingOffer: IncomingDeliveryOffer(
        orderType: DeliveryOrderType.deliveryRequest,
        orderId: payload['delivery_id'] as String,
        pickupLabel: payload['pickup_address'] as String? ?? '',
        dropoffLabel: payload['dropoff_address'] as String? ?? '',
        distanceKm: (payload['distance_km'] as num?)?.toDouble(),
        price: (payload['price'] as num?)?.toDouble(),
      ),
    );
    _startOfferCountdown();
  }

  /// The broadcast payload for a food-order leg only carries `order_id` —
  /// fetch the restaurant name + delivery address before showing the sheet.
  Future<void> _onIncomingFoodLeg(Map<String, dynamic> payload) async {
    if (state.activeDelivery != null || state.incomingOffer != null) return;
    final orderId = payload['order_id'] as String?;
    if (orderId == null) return;
    try {
      final row = await _sb
          .from('food_orders')
          .select('id, delivery_address, total, restaurant_id, restaurants(name)')
          .eq('id', orderId)
          .maybeSingle();
      if (row == null || state.activeDelivery != null || state.incomingOffer != null) return;
      final restaurant = row['restaurants'] as Map<String, dynamic>?;
      state = state.copyWith(
        incomingOffer: IncomingDeliveryOffer(
          orderType: DeliveryOrderType.foodOrder,
          orderId: orderId,
          pickupLabel: restaurant?['name'] as String? ?? 'مطعم',
          dropoffLabel: row['delivery_address'] as String? ?? '',
          price: (row['total'] as num?)?.toDouble(),
        ),
      );
      _startOfferCountdown();
    } catch (_) {
      // Offer just doesn't show — the platform's own 20s window on the
      // matching side moves on to another livreur.
    }
  }

  String _apiOrderType(DeliveryOrderType t) => t == DeliveryOrderType.deliveryRequest ? 'delivery_request' : 'food_order';

  Future<void> acceptIncoming() async {
    final offer = state.incomingOffer;
    if (offer == null) return;
    _incomingTimer?.cancel();
    state = state.copyWith(incomingOffer: null);
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': _apiOrderType(offer.orderType), 'order_id': offer.orderId, 'decision': 'accept'},
      );
      await _loadActiveDelivery(offer.orderType, offer.orderId);
      goTo(LivreurScreen.navigateToPickup);
    } catch (e) {
      // Most common cause: another livreur claimed it first (409).
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  Future<void> rejectIncoming() async {
    final offer = state.incomingOffer;
    _incomingTimer?.cancel();
    state = state.copyWith(incomingOffer: null);
    if (offer == null) return;
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': _apiOrderType(offer.orderType), 'order_id': offer.orderId, 'decision': 'reject'},
      );
    } catch (_) {
      // Reject is a no-op server-side — nothing to recover from.
    }
  }

  Future<void> _loadActiveDelivery(DeliveryOrderType type, String orderId) async {
    if (type == DeliveryOrderType.deliveryRequest) {
      final row = await _sb.from('delivery_requests').select().eq('id', orderId).single();
      state = state.copyWith(
        activeDelivery: ActiveDelivery(
          orderType: type,
          orderId: orderId,
          clientId: row['client_id'] as String,
          pickupLabel: row['pickup_address'] as String? ?? '',
          dropoffLabel: row['dropoff_address'] as String? ?? '',
          price: (row['price'] as num?)?.toDouble() ?? 0,
          status: row['status'] as String? ?? 'accepted',
          distanceKm: (row['distance_km'] as num?)?.toDouble(),
          recipientName: row['recipient_name'] as String?,
          recipientPhone: row['recipient_phone'] as String?,
        ),
      );
      unawaited(_fetchCommissionPct('delivery'));
    } else {
      final row =
          await _sb.from('food_orders').select('id, client_id, delivery_address, total, status, restaurants(name)').eq('id', orderId).single();
      final restaurant = row['restaurants'] as Map<String, dynamic>?;
      state = state.copyWith(
        activeDelivery: ActiveDelivery(
          orderType: type,
          orderId: orderId,
          clientId: row['client_id'] as String,
          pickupLabel: restaurant?['name'] as String? ?? 'مطعم',
          dropoffLabel: row['delivery_address'] as String? ?? '',
          price: (row['total'] as num?)?.toDouble() ?? 0,
          status: row['status'] as String? ?? 'out_for_delivery',
        ),
      );
      unawaited(_fetchCommissionPct('food'));
    }
  }

  // ---------------------------------------------------------------------
  // Delivery trip — real `update-order-status`
  // ---------------------------------------------------------------------
  /// Standalone parcels have an explicit `picked_up` status; the food-order
  /// leg doesn't (a livreur claiming it already moves it to
  /// `out_for_delivery` — see `update-order-status`'s `markFoodOrderReadyAndSearchLivreur`),
  /// so picking up from the restaurant is a local-only screen transition.
  Future<void> markPickedUp() async {
    final delivery = state.activeDelivery;
    if (delivery != null && delivery.orderType == DeliveryOrderType.deliveryRequest) {
      try {
        await _sb.functions.invoke(
          'update-order-status',
          body: {'order_type': 'delivery_request', 'order_id': delivery.orderId, 'next_status': 'picked_up'},
        );
        state = state.copyWith(activeDelivery: delivery.copyWith(status: 'picked_up'));
      } catch (e) {
        state = state.copyWith(actionError: _functionErrorMessage(e));
        return;
      }
    }
    goTo(LivreurScreen.navigateToDropoff);
  }

  Future<void> markDelivered() async {
    final delivery = state.activeDelivery;
    if (delivery != null) {
      try {
        await _sb.functions.invoke(
          'update-order-status',
          body: {'order_type': _apiOrderType(delivery.orderType), 'order_id': delivery.orderId, 'next_status': 'delivered'},
        );
        state = state.copyWith(activeDelivery: delivery.copyWith(status: 'delivered'));
      } catch (e) {
        state = state.copyWith(actionError: _functionErrorMessage(e));
        return;
      }
    }
    goTo(LivreurScreen.deliveryEnd);
  }

  void goToRateCustomer() => goTo(LivreurScreen.rateCustomer);

  void rateCustomer(int stars) => state = state.copyWith(custRating: stars);

  Future<void> finishRating({String? comment}) async {
    final delivery = state.activeDelivery;
    final uid = _sb.auth.currentUser?.id;
    if (delivery != null && uid != null && state.custRating > 0) {
      try {
        await _sb.from('ratings').insert({
          'order_id': delivery.orderId,
          'order_type': _apiOrderType(delivery.orderType),
          'rated_by': uid,
          'rated_entity_type': 'client',
          'rated_entity_id': delivery.clientId,
          'rating': state.custRating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        });
      } catch (_) {
        // Non-fatal — the delivery is already completed and paid.
      }
    }
    goTo(LivreurScreen.home, patch: (s) => s.copyWith(custRating: 0, activeDelivery: null));
  }
}
