import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dish.dart';
import 'food_flow_state.dart';
import 'food_screen.dart';

final foodFlowControllerProvider = StateNotifierProvider<FoodFlowController, FoodFlowState>(
  (ref) => FoodFlowController(),
);

/// Ports the original design prototype's `Component` class. Real backend
/// pieces (everything the schema already supports without an Edge
/// Function):
///  - Auth (login/signup/sign-out).
///  - `submitRestaurantDocs`/`submitBikeDocs` really insert into
///    `restaurants`/`vehicles`; the Pending/Rejected screens watch the
///    restaurant row live via Realtime.
///  - Wallet balance, watched live.
///  - **Menu management** (screen 67) is fully real CRUD against
///    `restaurant_dish_categories`/`restaurant_dishes` — add dish, toggle
///    availability/delivery, adjust stock.
///  - **Delivery settings** (screen: طريقة التوصيل) persists to the new
///    `restaurants.delivery_method/delivery_fee/min_order/prep_time_minutes`
///    columns (see supabase/migrations/20260801130001_...).
/// Incoming orders / order detail / reports stay simulated — they need
/// `request-food-order`/`respond-to-order` (Section 2, not built) to ever
/// have real rows to show.
class FoodFlowController extends StateNotifier<FoodFlowState> {
  FoodFlowController() : super(const FoodFlowState());

  StreamSubscription<List<Map<String, dynamic>>>? _restaurantSub;
  StreamSubscription<List<Map<String, dynamic>>>? _walletSub;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSub;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void dispose() {
    _restaurantSub?.cancel();
    _walletSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }

  void clearActionError() => state = state.copyWith(actionError: null);

  String _functionErrorMessage(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) return details['error'] as String;
    }
    return 'حدث خطأ، حاول مجددًا';
  }

  void goTo(FoodScreen screen, {FoodFlowState Function(FoodFlowState)? patch}) {
    final withHist = state.copyWith(hist: [...state.hist, state.screen]);
    state = patch != null ? patch(withHist).copyWith(screen: screen) : withHist.copyWith(screen: screen);
  }

  void back() {
    final hist = [...state.hist];
    final prev = hist.isNotEmpty ? hist.removeLast() : FoodScreen.home;
    state = state.copyWith(screen: prev, hist: hist);
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
      watchWallet();
      final uid = _sb.auth.currentUser?.id;
      // A returning (already-verified) owner has no restaurantId yet at
      // this point — submitRestaurantDocs only sets it during first-time
      // onboarding. watchRestaurantStatus also back-fills it from the row,
      // which watchOrders below needs to subscribe to the right channel.
      if (uid != null) watchRestaurantStatus(uid);
      unawaited(_fetchCommissionPct());
      goTo(FoodScreen.home);
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تسجيل الدخول، حاول مجددًا');
    }
  }

  Future<void> doSignup() async {
    if (state.password != state.confirmPassword) {
      state = state.copyWith(authError: 'كلمتا المرور غير متطابقتين');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // Only creates the auth.users row — profiles/wallets (role=
      // 'restaurant_owner') are created by `register-provider` (Section 2).
      await _sb.auth.signUp(email: state.email.trim(), password: state.password, data: {'full_name': state.fullName});
      state = state.copyWith(isSubmitting: false);
      goTo(FoodScreen.otp);
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إنشاء الحساب، حاول مجددًا');
    }
  }

  /// The original code here never actually called `register-provider` —
  /// the comment above claiming profiles/wallets "are created by
  /// register-provider" was aspirational, not real. Every restaurant-owner
  /// signup ended up with an `auth.users` row but no `profiles` row, which
  /// then made `submitRestaurantDocs`'s insert fail on the `restaurants
  /// .owner_id` foreign key — a confusing "تعذّر إرسال بيانات المطعم" that
  /// would fail identically on every retry since the real cause (no
  /// profile) was never fixed by retrying.
  Future<void> confirmOtp() async {
    try {
      await _sb.functions.invoke('register-provider', body: {'role': 'restaurant_owner', 'full_name': state.fullName});
    } catch (_) {
      // Non-fatal — restaurantDocs submission below still works even if
      // this races the auth session; register-provider is idempotent.
    }
    goTo(FoodScreen.restaurantDocs);
  }

  /// Self-heals accounts stuck with an `auth.users` row but no `profiles`/
  /// `wallets` row — safe to call on every login since `register-provider`
  /// is idempotent (returns immediately if a profile already exists).
  Future<void> _ensureProfile() async {
    try {
      final fullName = _sb.auth.currentUser?.userMetadata?['full_name'] as String? ?? '';
      await _sb.functions.invoke('register-provider', body: {'role': 'restaurant_owner', 'full_name': fullName.trim().isEmpty ? 'مستخدم' : fullName});
    } catch (_) {
      // Non-fatal — same reasoning as the OTP-confirm call site.
    }
  }

  Future<void> signOut() async {
    await _restaurantSub?.cancel();
    await _walletSub?.cancel();
    await _ordersSub?.cancel();
    await _sb.auth.signOut();
    state = const FoodFlowState();
  }

  // ---------------------------------------------------------------------
  // Restaurant + bike verification — real insert + Realtime watch
  // ---------------------------------------------------------------------
  void toggleDoc() => state = state.copyWith(doc1: !state.doc1);
  void toggleDoc2() => state = state.copyWith(doc2: !state.doc2);

  Future<void> submitRestaurantDocs({
    required String name,
    required String address,
    required String cuisineType,
    required String openingHours,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(FoodScreen.bikeDocs);
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      // No real map picker in this design yet (the field is a free-text
      // address); placeholder location until Maps SDK is wired in
      // (Nouakchott city-center coordinates).
      //
      // upsert, not insert — a plain insert let re-submitting silently
      // create a second `restaurants` row for the same owner, which would
      // break any single-row lookup keyed on owner_id the same way it did
      // for `vehicles`/`toggle-online-status` (see that fix's comment).
      final row = await _sb
          .from('restaurants')
          .upsert({
            'owner_id': uid,
            'name': name,
            'address': address,
            'location': 'POINT(-15.9785 18.0858)',
            'license_url': state.doc1 ? 'pending-upload' : '',
            'cuisine_type': cuisineType,
            'opening_hours': {'raw': openingHours},
          }, onConflict: 'owner_id')
          .select()
          .single();
      state = state.copyWith(isSubmitting: false, restaurantId: row['id'] as String);
      watchRestaurantStatus(uid);
      goTo(FoodScreen.bikeDocs);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إرسال بيانات المطعم، حاول مجددًا');
    }
  }

  Future<void> submitBikeDocs({
    required String vehicleName,
    required String address,
    required String bikeType,
    required String plateNumber,
    required String notes,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(FoodScreen.pendingApproval);
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
        'driving_license_url': state.doc2 ? 'pending-upload' : '',
        'car_type': bikeType,
        'plate_number': plateNumber,
        'notes': notes,
      }, onConflict: 'owner_id,service_type');
      state = state.copyWith(isSubmitting: false);
      goTo(FoodScreen.pendingApproval);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر إرسال بيانات الدراجة، حاول مجددًا');
    }
  }

  void watchRestaurantStatus(String uid) {
    _restaurantSub?.cancel();
    _restaurantSub = _sb
        .from('restaurants')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .order('created_at')
        .listen((rows) {
      if (rows.isEmpty) return;
      final latest = rows.last;
      final status = latest['status'] as String?;
      final restaurantId = latest['id'] as String;
      state = state.copyWith(
        restaurantId: restaurantId,
        restaurantStatus: status,
        restaurantRejectionReason: latest['rejection_reason'] as String?,
      );
      watchOrders(restaurantId);
      if (status == 'rejected' && state.screen == FoodScreen.pendingApproval) {
        goTo(FoodScreen.rejected);
      } else if (status == 'verified' && state.screen == FoodScreen.pendingApproval) {
        goTo(FoodScreen.home);
      }
    });
  }

  /// Design-only preview button (screen 64) — the real transition happens
  /// automatically via `watchRestaurantStatus` once an admin actually rejects.
  void simulateRejected() => goTo(FoodScreen.rejected);

  // ---------------------------------------------------------------------
  // Wallet — real read + Realtime watch
  // ---------------------------------------------------------------------
  void watchWallet() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    _walletSub?.cancel();
    _walletSub = _sb.from('wallets').stream(primaryKey: ['id']).eq('owner_id', uid).listen((rows) {
      if (rows.isEmpty) {
        return;
      }
      final balance = (rows.first['balance'] as num?)?.toDouble();
      state = state.copyWith(balance: balance);
    });
  }

  // ---------------------------------------------------------------------
  // Home / open toggle — real `toggle-online-status`
  // ---------------------------------------------------------------------
  Future<void> toggleOpen() async {
    if (state.lowBalance) return;
    final target = !state.open;
    try {
      final res = await _sb.functions.invoke('toggle-online-status', body: {'online': target});
      final open = (res.data as Map)['online'] as bool? ?? target;
      state = state.copyWith(open: open);
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  void toggleLowBalanceDemo() => state = state.copyWith(
        lowBalanceDemo: !state.lowBalanceDemo,
        open: state.lowBalanceDemo ? state.open : false,
      );

  // ---------------------------------------------------------------------
  // Menu management — real CRUD
  // ---------------------------------------------------------------------
  void toggleAddDish() => state = state.copyWith(addDishOpen: !state.addDishOpen);

  Future<void> loadMenu() async {
    final restaurantId = state.restaurantId;
    if (restaurantId == null) return;
    state = state.copyWith(menuLoading: true);
    try {
      final catRows = await _sb
          .from('restaurant_dish_categories')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('sort_order');
      final dishRows = await _sb.from('restaurant_dishes').select().eq('restaurant_id', restaurantId);
      state = state.copyWith(
        categories: catRows.map(DishCategory.fromRow).toList(),
        dishes: dishRows.map(Dish.fromRow).toList(),
        menuLoading: false,
      );
    } catch (_) {
      state = state.copyWith(menuLoading: false);
    }
  }

  Future<void> addDish(String name, num price) async {
    final restaurantId = state.restaurantId;
    if (restaurantId == null || name.trim().isEmpty) return;

    var categoryId = state.categories.isNotEmpty ? state.categories.first.id : null;
    if (categoryId == null) {
      final newCat = await _sb
          .from('restaurant_dish_categories')
          .insert({'restaurant_id': restaurantId, 'name': 'الطبق الرئيسي', 'sort_order': 0})
          .select()
          .single();
      categoryId = newCat['id'] as String;
      state = state.copyWith(categories: [...state.categories, DishCategory.fromRow(newCat)]);
    }

    final row = await _sb
        .from('restaurant_dishes')
        .insert({'restaurant_id': restaurantId, 'category_id': categoryId, 'name': name.trim(), 'price': price})
        .select()
        .single();
    state = state.copyWith(dishes: [...state.dishes, Dish.fromRow(row)], addDishOpen: false);
  }

  Future<void> toggleDishAvailable(Dish dish) async {
    final updated = dish.copyWith(isAvailable: !dish.isAvailable);
    _patchDish(updated);
    await _sb.from('restaurant_dishes').update({'is_available': updated.isAvailable}).eq('id', dish.id);
  }

  Future<void> toggleDishDelivery(Dish dish) async {
    final updated = dish.copyWith(availableForDelivery: !dish.availableForDelivery);
    _patchDish(updated);
    await _sb.from('restaurant_dishes').update({'available_for_delivery': updated.availableForDelivery}).eq('id', dish.id);
  }

  Future<void> changeStock(Dish dish, int delta) async {
    final updated = dish.copyWith(stock: (dish.stock + delta).clamp(0, 1 << 30));
    _patchDish(updated);
    await _sb.from('restaurant_dishes').update({'stock_quantity': updated.stock}).eq('id', dish.id);
  }

  void _patchDish(Dish updated) {
    state = state.copyWith(dishes: [for (final d in state.dishes) if (d.id == updated.id) updated else d]);
  }

  /// The design's own "+ تصنيف جديد" is a no-op stub (no input form was
  /// designed for it either) — kept as-is rather than inventing a UI the
  /// design doesn't specify.
  void addCategoryDemo() {}

  // ---------------------------------------------------------------------
  // Delivery settings — real update
  // ---------------------------------------------------------------------
  void setDeliveryMethod(DeliveryMethod m) => state = state.copyWith(deliveryMethod: m);
  void setDeliveryFee(String v) => state = state.copyWith(deliveryFee: v);
  void setMinOrder(String v) => state = state.copyWith(minOrder: v);
  void setPrepTime(String v) => state = state.copyWith(prepTime: v);

  Future<void> saveDeliverySettings() async {
    final restaurantId = state.restaurantId;
    if (restaurantId != null) {
      await _sb.from('restaurants').update({
        'delivery_method': state.deliveryMethod.name,
        'delivery_fee': num.tryParse(state.deliveryFee) ?? 0,
        'min_order': num.tryParse(state.minOrder) ?? 0,
        'prep_time_minutes': state.prepTime,
      }).eq('id', restaurantId);
    }
    back();
  }

  // ---------------------------------------------------------------------
  // Orders — real Realtime stream + respond-to-order/update-order-status
  // ---------------------------------------------------------------------
  Future<void> _fetchCommissionPct() async {
    try {
      final row = await _sb.from('commission_settings').select('percentage').eq('service_type', 'food').maybeSingle();
      if (row != null) state = state.copyWith(commissionPct: (row['percentage'] as num).toDouble());
    } catch (_) {
      // Display-only.
    }
  }

  /// Unlike taxi/livreur (which match a broadcast fan-out to many nearby
  /// providers before any of them can even SELECT the order row), a food
  /// order is always tied to exactly one restaurant from the moment
  /// `request-food-order` creates it — RLS already lets this owner select
  /// it regardless of status. A plain postgres-changes stream is therefore
  /// simpler and sufficient here; no Broadcast channel is needed the way it
  /// is for the other two apps' provider-matching flow.
  void watchOrders(String restaurantId) {
    _ordersSub?.cancel();
    _ordersSub = _sb
        .from('food_orders')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false)
        .listen((rows) {
      final newOrders = <Map<String, dynamic>>[];
      final prepOrders = <Map<String, dynamic>>[];
      final readyOrders = <Map<String, dynamic>>[];
      final doneOrders = <Map<String, dynamic>>[];
      for (final row in rows) {
        switch (row['status'] as String?) {
          case 'pending_restaurant':
            newOrders.add(row);
          case 'accepted':
          case 'preparing':
            prepOrders.add(row);
          case 'ready':
          case 'searching_livreur':
          case 'no_livreur_found':
          case 'out_for_delivery':
            readyOrders.add(row);
          case 'delivered':
          case 'completed':
            doneOrders.add(row);
        }
      }
      state = state.copyWith(newOrders: newOrders, prepOrders: prepOrders, readyOrders: readyOrders, doneOrders: doneOrders);
    });
  }

  void setOrderTab(OrderTab tab) => state = state.copyWith(orderTab: tab);

  void openOrderDetail(String orderId) => goTo(FoodScreen.orderDetail, patch: (s) => s.copyWith(selectedOrderId: orderId));

  Future<void> acceptOrder(String orderId) async {
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'food_order', 'order_id': orderId, 'decision': 'accept'},
      );
      // watchOrders' stream picks up the status change and moves the card
      // to the "prep" tab on its own.
      state = state.copyWith(orderTab: OrderTab.prep);
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'food_order', 'order_id': orderId, 'decision': 'reject'},
      );
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  /// `accepted -> preparing` is a required intermediate step in
  /// `update-order-status`'s state machine (only `preparing` can advance to
  /// `ready`) — a second explicit action, not folded into `acceptOrder`.
  Future<void> markOrderPreparing(String orderId) async {
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': 'food_order', 'order_id': orderId, 'next_status': 'preparing'},
      );
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }

  Future<void> markOrderReady(String orderId) async {
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': 'food_order', 'order_id': orderId, 'next_status': 'ready'},
      );
      state = state.copyWith(orderTab: OrderTab.ready);
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
    }
  }
}
