import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/push_notifications.dart';
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
///  - **Incoming orders / order detail** (screens 68-69) are real too —
///    `watchOrders()` streams `food_orders` live, bucketed by status.
/// Reports (screen: التقارير) still shows demo numbers — no aggregation
/// query/RPC exists yet for real revenue/order-count analytics.
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
      unawaited(_fetchCommissionPct());
      unawaited(PushNotifications.register());
      await _routeAfterAuth();
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, authError: e.message);
    } catch (_) {
      state = state.copyWith(isSubmitting: false, authError: 'تعذّر تسجيل الدخول، حاول مجددًا');
    }
  }

  /// Splash's "متابعة" used to always go to Login, even with a persisted
  /// Supabase session — forcing a full re-login on every process restart.
  /// If a session already exists, skip straight to the same post-auth
  /// routing `doLogin()` uses instead.
  Future<void> continueFromSplash() async {
    if (_sb.auth.currentSession != null) {
      unawaited(_ensureProfile());
      watchWallet();
      unawaited(_fetchCommissionPct());
      unawaited(PushNotifications.register());
      await _routeAfterAuth();
    } else {
      goTo(FoodScreen.login);
    }
  }

  /// Single source of truth for "where does this restaurant owner belong
  /// right now", used by both a fresh login and a resumed session.
  /// Previously `doLogin` always went straight to the fully-operational
  /// Home screen regardless of verification status — a pending or rejected
  /// owner who logged back in (or just relaunched the app once
  /// session-restore existed) landed on Home with the online toggle, menu,
  /// and orders all live, instead of `PendingApproval`/`Rejected`. Also
  /// restores `restaurants.is_open` into local state — without this, a
  /// returning owner who was genuinely open for orders saw a fabricated
  /// "closed" toggle after every relaunch, exactly the bug already fixed
  /// for the taxi app's `vehicles.is_online` this session.
  Future<void> _routeAfterAuth() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(FoodScreen.login);
      return;
    }
    try {
      final row = await _sb
          .from('restaurants')
          .select('id, name, logo_url, cuisine_type, status, rejection_reason, is_open')
          .eq('owner_id', uid)
          .order('created_at')
          .limit(1)
          .maybeSingle();
      if (row == null) {
        goTo(FoodScreen.restaurantDocs);
        return;
      }
      final restaurantId = row['id'] as String;
      final status = row['status'] as String?;
      state = state.copyWith(
        restaurantId: restaurantId,
        restaurantName: row['name'] as String?,
        restaurantLogoUrl: row['logo_url'] as String?,
        restaurantCuisineType: row['cuisine_type'] as String?,
        restaurantStatus: status,
        restaurantRejectionReason: row['rejection_reason'] as String?,
        open: row['is_open'] == true,
      );
      // Always subscribed (not just for `pending`) — unlike the taxi app's
      // equivalent, this same stream is also what starts `watchOrders`.
      watchRestaurantStatus(uid);
      if (status == 'pending') {
        goTo(FoodScreen.pendingApproval);
      } else if (status == 'rejected') {
        goTo(FoodScreen.rejected);
      } else {
        goTo(FoodScreen.home);
      }
    } catch (_) {
      goTo(FoodScreen.home);
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

  /// No delete-account path existed anywhere in this app, even though the
  /// server side (`delete-account` Edge Function) already fully supports
  /// the `restaurant_owner` role — blocked while any `food_orders` row is
  /// still active (as client, restaurant owner, or livreur), and the
  /// anonymize/ban fallback already takes `restaurants.is_open` offline.
  ///
  /// Returns the error message on failure (null on success) instead of a
  /// plain bool — `AppRoot`'s global listener reads and clears
  /// `state.actionError` synchronously the instant it's set, so a caller
  /// that re-reads it after this `await` returns would always find it
  /// already `null` (the exact bug this avoids, already hit and fixed in
  /// the taxi/client apps this session).
  Future<String?> deleteAccount() async {
    try {
      await _sb.functions.invoke('delete-account');
    } catch (e) {
      final message = _functionErrorMessage(e);
      state = state.copyWith(actionError: message);
      return message;
    }
    await _restaurantSub?.cancel();
    await _walletSub?.cancel();
    await _ordersSub?.cancel();
    try {
      await _sb.auth.signOut();
    } catch (_) {
      // Best-effort — the server-side account is already gone either way.
    }
    state = const FoodFlowState();
    return null;
  }

  // ---------------------------------------------------------------------
  // Restaurant + bike verification — real insert + Realtime watch
  // ---------------------------------------------------------------------
  void toggleDoc2() => state = state.copyWith(doc2: !state.doc2);

  void setPickedLocation(double lat, double lng, String address) =>
      state = state.copyWith(pickedLat: lat, pickedLng: lng, pickedAddress: address);

  /// Uploads to the private `restaurant-docs` bucket (admin-only viewing,
  /// same ownership model as `vehicle-docs` — see that bucket's migration
  /// comment). Previously "رفع رخصة/وثيقة النشاط" was just a boolean toggle
  /// with no real file behind it at all — `submitRestaurantDocs` always
  /// wrote either `''` or the literal string `'pending-upload'`, so admin
  /// review had no actual document to look at, ever.
  Future<void> pickAndUploadLicense(ImageSource source) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    state = state.copyWith(licenseUploading: true, authError: null);
    try {
      final bytes = await picked.readAsBytes();
      await _sb.storage.from('restaurant-docs').uploadBinary(
            '$uid/license.jpg',
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      state = state.copyWith(licenseUploading: false, doc1: true);
    } catch (_) {
      state = state.copyWith(licenseUploading: false, authError: 'تعذّر رفع الصورة، حاول مجددًا');
    }
  }

  /// Uploads to the public `public-images` bucket — the logo is
  /// customer-facing (shown in the client app's restaurant list/detail
  /// screens), unlike the license.
  /// Also usable after onboarding — tapping the avatar on the Profile
  /// screen re-uploads and immediately patches the live `restaurants` row
  /// (during onboarding itself `restaurantId` doesn't exist yet, so that
  /// part is skipped and `submitRestaurantDocs` writes `logo_url` once the
  /// row is first created).
  Future<void> pickAndUploadLogo(ImageSource source) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    state = state.copyWith(logoUploading: true, authError: null);
    try {
      final bytes = await picked.readAsBytes();
      final path = '$uid/restaurant-logo.jpg';
      await _sb.storage.from('public-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final restaurantId = state.restaurantId;
      if (restaurantId != null) {
        final url = _sb.storage.from('public-images').getPublicUrl(path);
        final bustedUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
        await _sb.from('restaurants').update({'logo_url': bustedUrl}).eq('id', restaurantId);
        state = state.copyWith(restaurantLogoUrl: bustedUrl);
      }
      state = state.copyWith(logoUploading: false, logoUploaded: true);
    } catch (_) {
      state = state.copyWith(logoUploading: false, authError: 'تعذّر رفع الصورة، حاول مجددًا');
    }
  }

  /// Onboarding simplified to exactly 4 fields per an explicit product
  /// request: restaurant name, business license, a real map-tap address
  /// (was free-text), and a logo — cuisine type and the opening-hours text
  /// field are gone from here (the dedicated Working Hours screen is the
  /// real source of truth for hours; cuisine type just wasn't asked for).
  Future<void> submitRestaurantDocs({required String name}) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      goTo(FoodScreen.bikeDocs);
      return;
    }
    if (name.trim().isEmpty) {
      state = state.copyWith(authError: 'أدخل اسم المطعم');
      return;
    }
    if (state.pickedLat == null || state.pickedLng == null) {
      state = state.copyWith(authError: 'حدد عنوان المطعم على الخريطة');
      return;
    }
    if (!state.doc1) {
      state = state.copyWith(authError: 'ارفع رخصة النشاط');
      return;
    }
    if (!state.logoUploaded) {
      state = state.copyWith(authError: 'ارفع شعار المطعم');
      return;
    }
    state = state.copyWith(isSubmitting: true, authError: null);
    try {
      final logoUrl = _sb.storage.from('public-images').getPublicUrl('$uid/restaurant-logo.jpg');
      // upsert, not insert — a plain insert let re-submitting silently
      // create a second `restaurants` row for the same owner, which would
      // break any single-row lookup keyed on owner_id the same way it did
      // for `vehicles`/`toggle-online-status` (see that fix's comment).
      final row = await _sb
          .from('restaurants')
          .upsert({
            'owner_id': uid,
            'name': name.trim(),
            'address': state.pickedAddress ?? '',
            'location': 'POINT(${state.pickedLng} ${state.pickedLat})',
            'license_url': '$uid/license.jpg',
            'logo_url': logoUrl,
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
        restaurantName: latest['name'] as String?,
        restaurantLogoUrl: latest['logo_url'] as String?,
        restaurantCuisineType: latest['cuisine_type'] as String?,
        restaurantStatus: status,
        restaurantRejectionReason: latest['rejection_reason'] as String?,
        open: latest['is_open'] == true,
      );
      watchOrders(restaurantId);
      if (status == 'rejected' && state.screen == FoodScreen.pendingApproval) {
        goTo(FoodScreen.rejected);
      } else if (status == 'verified' && state.screen == FoodScreen.pendingApproval) {
        goTo(FoodScreen.home);
      }
    });
  }

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
      final walletId = rows.first['id'] as String?;
      final isFirstLoad = state.walletId == null;
      state = state.copyWith(balance: balance, walletId: walletId);
      // Only need to (re)fetch the transaction list once we first learn the
      // wallet id — the balance itself already updates live via this same
      // stream on every subsequent emission.
      if (isFirstLoad && walletId != null) unawaited(loadWalletTransactions());
    });
  }

  /// The wallet screen used to show 2 hardcoded transaction rows regardless
  /// of what actually happened — a real top-up (e.g. from the admin panel)
  /// never appeared anywhere, which reads exactly like "the balance I added
  /// didn't show up" even though `wallets.balance` itself (shown just above
  /// this list) was already updating correctly live.
  Future<void> loadWalletTransactions() async {
    final walletId = state.walletId;
    if (walletId == null) return;
    try {
      final rows = await _sb
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', walletId)
          .order('created_at', ascending: false)
          .limit(30);
      state = state.copyWith(walletTransactions: List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // Non-fatal — the wallet screen just won't show history this time.
    }
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

  /// A photo is now required — `restaurant_dishes.image_url` already
  /// existed in the schema, but nothing ever uploaded one, and the model's
  /// own `emoji` getter (now removed) would have rendered the raw URL
  /// string as if it were an emoji character had a value ever gotten in
  /// there. Uploads to the public `public-images` bucket (customers browsing
  /// the menu need to see this without auth) at a per-dish path, then
  /// patches the just-inserted row with the resulting URL.
  Future<void> addDish(String name, num price, Uint8List imageBytes) async {
    final restaurantId = state.restaurantId;
    final uid = _sb.auth.currentUser?.id;
    if (restaurantId == null || uid == null || name.trim().isEmpty) return;
    try {
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
      final dishId = row['id'] as String;

      final path = '$uid/dishes/$dishId.jpg';
      await _sb.storage.from('public-images').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final imageUrl = _sb.storage.from('public-images').getPublicUrl(path);
      await _sb.from('restaurant_dishes').update({'image_url': imageUrl}).eq('id', dishId);

      state = state.copyWith(dishes: [...state.dishes, Dish.fromRow({...row, 'image_url': imageUrl})], addDishOpen: false);
    } catch (_) {
      // The add-dish panel used to have no try/catch at all — any failure
      // (network, RLS) threw unhandled, leaving "حفظ الطبق" appearing to do
      // nothing with zero feedback and the panel stuck open.
      state = state.copyWith(actionError: 'تعذّر إضافة الطبق، حاول مجددًا');
    }
  }

  /// The 3 toggles below used to flip local state *before* awaiting the
  /// server write, with no try/catch at all — a failed update (network,
  /// RLS) left the UI showing a change (e.g. a "sold out" dish still
  /// marked available) that never actually happened in the database, with
  /// no error and no way for the owner to know. Now rolls the optimistic
  /// patch back and surfaces the real error on failure.
  Future<void> toggleDishAvailable(Dish dish) async {
    final previous = dish;
    final updated = dish.copyWith(isAvailable: !dish.isAvailable);
    _patchDish(updated);
    try {
      await _sb.from('restaurant_dishes').update({'is_available': updated.isAvailable}).eq('id', dish.id);
    } catch (_) {
      _patchDish(previous);
      state = state.copyWith(actionError: 'تعذّر تحديث حالة الطبق، حاول مجددًا');
    }
  }

  Future<void> toggleDishDelivery(Dish dish) async {
    final previous = dish;
    final updated = dish.copyWith(availableForDelivery: !dish.availableForDelivery);
    _patchDish(updated);
    try {
      await _sb.from('restaurant_dishes').update({'available_for_delivery': updated.availableForDelivery}).eq('id', dish.id);
    } catch (_) {
      _patchDish(previous);
      state = state.copyWith(actionError: 'تعذّر تحديث حالة الطبق، حاول مجددًا');
    }
  }

  Future<void> changeStock(Dish dish, int delta) async {
    final previous = dish;
    final updated = dish.copyWith(stock: (dish.stock + delta).clamp(0, 1 << 30));
    _patchDish(updated);
    try {
      await _sb.from('restaurant_dishes').update({'stock_quantity': updated.stock}).eq('id', dish.id);
    } catch (_) {
      _patchDish(previous);
      state = state.copyWith(actionError: 'تعذّر تحديث الكمية، حاول مجددًا');
    }
  }

  void _patchDish(Dish updated) {
    state = state.copyWith(dishes: [for (final d in state.dishes) if (d.id == updated.id) updated else d]);
  }

  /// Was a literal no-op stub — "+ تصنيف جديد" did nothing when tapped, a
  /// real dead button in a screen that's otherwise fully wired to real
  /// menu CRUD. Inserts into the same `restaurant_dish_categories` table
  /// `loadMenu()`/`addDish()` already use.
  Future<void> addCategory(String name) async {
    final restaurantId = state.restaurantId;
    final trimmed = name.trim();
    if (restaurantId == null || trimmed.isEmpty) return;
    try {
      final row = await _sb
          .from('restaurant_dish_categories')
          .insert({'restaurant_id': restaurantId, 'name': trimmed, 'sort_order': state.categories.length})
          .select()
          .single();
      state = state.copyWith(categories: [...state.categories, DishCategory.fromRow(row)]);
    } catch (e) {
      state = state.copyWith(actionError: 'تعذّر إضافة التصنيف، حاول مجددًا');
    }
  }

  // ---------------------------------------------------------------------
  // Delivery settings — real update
  // ---------------------------------------------------------------------
  void setDeliveryMethod(DeliveryMethod m) => state = state.copyWith(deliveryMethod: m);
  void setDeliveryFee(String v) => state = state.copyWith(deliveryFee: v);
  void setMinOrder(String v) => state = state.copyWith(minOrder: v);
  void setPrepTime(String v) => state = state.copyWith(prepTime: v);

  Future<void> saveDeliverySettings() async {
    final restaurantId = state.restaurantId;
    if (restaurantId == null) {
      back();
      return;
    }
    try {
      await _sb.from('restaurants').update({
        'delivery_method': state.deliveryMethod.name,
        'delivery_fee': num.tryParse(state.deliveryFee) ?? 0,
        'min_order': num.tryParse(state.minOrder) ?? 0,
        'prep_time_minutes': state.prepTime,
      }).eq('id', restaurantId);
      back();
    } catch (_) {
      // Unlike `saveWorkingHours` right below this, this had no try/catch
      // at all — a failed update threw before `back()` ever ran, leaving
      // "حفظ" looking like it just hung, with the settings never actually
      // saved.
      state = state.copyWith(actionError: 'تعذّر حفظ إعدادات التوصيل، حاول مجددًا');
    }
  }

  // ---------------------------------------------------------------------
  // Working hours — real read/write against restaurants.opening_hours (jsonb)
  // ---------------------------------------------------------------------
  static const _dayKeys = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
  static const _dayLabels = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  Future<void> loadWorkingHours() async {
    final restaurantId = state.restaurantId;
    if (restaurantId == null) return;
    try {
      final row = await _sb.from('restaurants').select('opening_hours').eq('id', restaurantId).single();
      final raw = (row['opening_hours'] as Map?) ?? {};
      state = state.copyWith(
        workingHours: [
          for (var i = 0; i < _dayKeys.length; i++)
            switch (raw[_dayKeys[i]]) {
              final Map d => {'day': _dayLabels[i], 'key': _dayKeys[i], 'open': d['open'] ?? true, 'from': d['from'] ?? '10:00', 'to': d['to'] ?? '23:00'},
              _ => {'day': _dayLabels[i], 'key': _dayKeys[i], 'open': true, 'from': '10:00', 'to': '23:00'},
            },
        ],
      );
    } catch (_) {
      // Falls back to the default all-open week already set above.
    }
  }

  void toggleWorkingHoursDay(int index) {
    final hours = [...state.workingHours];
    hours[index] = {...hours[index], 'open': !(hours[index]['open'] as bool)};
    state = state.copyWith(workingHours: hours);
  }

  /// "أي وقت" — an explicit request that hours be flexible rather than
  /// forcing a fixed from/to range for every open day. `00:00`–`23:59` is
  /// the sentinel this and `_DayRow` below both treat as "مرن/24 ساعة"; no
  /// schema change needed, `restaurants.opening_hours` already stores
  /// plain from/to strings per day.
  void toggleWorkingHours24h(int index) {
    final hours = [...state.workingHours];
    final day = hours[index];
    final is24h = day['from'] == '00:00' && day['to'] == '23:59';
    hours[index] = {...day, 'from': is24h ? '10:00' : '00:00', 'to': is24h ? '23:00' : '23:59'};
    state = state.copyWith(workingHours: hours);
  }

  void setWorkingHoursTime(int index, {String? from, String? to}) {
    final hours = [...state.workingHours];
    hours[index] = {...hours[index], if (from != null) 'from': from, if (to != null) 'to': to};
    state = state.copyWith(workingHours: hours);
  }

  Future<void> saveWorkingHours() async {
    final restaurantId = state.restaurantId;
    if (restaurantId != null) {
      final json = {
        for (final d in state.workingHours) d['key'] as String: {'open': d['open'], 'from': d['from'], 'to': d['to']},
      };
      try {
        await _sb.from('restaurants').update({'opening_hours': json}).eq('id', restaurantId);
      } catch (_) {
        state = state.copyWith(actionError: 'تعذّر حفظ أوقات العمل، حاول مجددًا');
        return;
      }
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

  /// Returns success so the order-detail screen can decide whether to
  /// navigate back — it used to fire-and-forget this call and navigate away
  /// immediately regardless, so a 409 ("another device already accepted
  /// this") left the owner already back on the list with no obvious link
  /// to the order that actually failed.
  Future<bool> acceptOrder(String orderId) async {
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'food_order', 'order_id': orderId, 'decision': 'accept'},
      );
      // watchOrders' stream picks up the status change and moves the card
      // to the "prep" tab on its own.
      state = state.copyWith(orderTab: OrderTab.prep);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    try {
      await _sb.functions.invoke(
        'respond-to-order',
        body: {'order_type': 'food_order', 'order_id': orderId, 'decision': 'reject'},
      );
      return true;
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
      return false;
    }
  }

  /// Previously there was no way to cancel an order from this app at all,
  /// even though `update-order-status`'s `advanceFoodOrder` has always
  /// allowed the restaurant to cancel from `accepted`/`preparing` (out of
  /// stock, closing early) — the capability existed server-side with no UI
  /// ever exposing it.
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _sb.functions.invoke(
        'update-order-status',
        body: {'order_type': 'food_order', 'order_id': orderId, 'next_status': 'cancelled'},
      );
      return true;
    } catch (e) {
      state = state.copyWith(actionError: _functionErrorMessage(e));
      return false;
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
