import 'dish.dart';
import 'food_screen.dart';

class FoodFlowState {
  const FoodFlowState({
    this.screen = FoodScreen.splash,
    this.hist = const [],
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.doc1 = false,
    this.doc2 = false,
    this.licenseUploading = false,
    this.logoUploaded = false,
    this.logoUploading = false,
    this.pickedLat,
    this.pickedLng,
    this.pickedAddress,
    this.open = false,
    this.lowBalanceDemo = false,
    this.balance,
    this.walletId,
    this.walletTransactions = const [],
    this.restaurantId,
    this.restaurantName,
    this.restaurantLogoUrl,
    this.restaurantCuisineType,
    this.restaurantStatus,
    this.restaurantRejectionReason,
    this.categories = const [],
    this.dishes = const [],
    this.menuLoading = false,
    this.addDishOpen = false,
    this.deliveryMethod = DeliveryMethod.afrigo,
    this.deliveryFee = '100',
    this.minOrder = '500',
    this.prepTime = '20-30 د',
    this.orderTab = OrderTab.newOrder,
    this.newOrders = const [],
    this.prepOrders = const [],
    this.readyOrders = const [],
    this.doneOrders = const [],
    this.selectedOrderId,
    this.commissionPct,
    this.workingHours = const [],
    this.isSubmitting = false,
    this.authError,
    this.actionError,
  });

  final FoodScreen screen;
  final List<FoodScreen> hist;

  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final bool doc1;
  final bool doc2;
  final bool licenseUploading;
  final bool logoUploaded;
  final bool logoUploading;

  /// Set live by the onboarding screen's `LocationPickerMap` — real
  /// map-tap address selection, replacing the old free-text address field.
  final double? pickedLat;
  final double? pickedLng;
  final String? pickedAddress;

  final bool open;
  final bool lowBalanceDemo;
  final double? balance;
  final String? walletId;
  final List<Map<String, dynamic>> walletTransactions;

  final String? restaurantId;
  final String? restaurantName;
  final String? restaurantLogoUrl;
  final String? restaurantCuisineType;
  final String? restaurantStatus;
  final String? restaurantRejectionReason;

  final List<DishCategory> categories;
  final List<Dish> dishes;
  final bool menuLoading;
  final bool addDishOpen;

  final DeliveryMethod deliveryMethod;
  final String deliveryFee;
  final String minOrder;
  final String prepTime;

  final OrderTab orderTab;

  /// Real `food_orders` rows for this restaurant, bucketed by status via
  /// `watchOrders()`'s Realtime stream — raw maps, same "no DTO layer"
  /// pattern as the rest of this monorepo. `newOrders` = pending_restaurant,
  /// `prepOrders` = accepted/preparing, `readyOrders` = ready/
  /// searching_livreur/no_livreur_found/out_for_delivery, `doneOrders` =
  /// delivered/completed.
  final List<Map<String, dynamic>> newOrders;
  final List<Map<String, dynamic>> prepOrders;
  final List<Map<String, dynamic>> readyOrders;
  final List<Map<String, dynamic>> doneOrders;
  final String? selectedOrderId;

  /// `commission_settings.percentage` for `food` — display only.
  final double? commissionPct;

  /// One entry per day: `{day, key, open, from, to}`. Loaded from/saved to
  /// `restaurants.opening_hours` (jsonb) by `loadWorkingHours`/
  /// `saveWorkingHours`.
  final List<Map<String, dynamic>> workingHours;

  final bool isSubmitting;
  final String? authError;
  final String? actionError;

  Map<String, dynamic>? get selectedOrder {
    if (selectedOrderId == null) return null;
    for (final list in [newOrders, prepOrders, readyOrders, doneOrders]) {
      for (final o in list) {
        if (o['id'] == selectedOrderId) return o;
      }
    }
    return null;
  }

  // 0, not a fabricated placeholder — `watchWallet()` is subscribed
  // immediately on login/resume, so this only shows briefly before the
  // first real balance arrives.
  double get resolvedBalance => balance ?? 0;
  bool get lowBalance => lowBalanceDemo || resolvedBalance <= 0;

  static bool _isToday(Map<String, dynamic> o) {
    final iso = o['created_at'] as String?;
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Home screen's 2 stat cards used to be hardcoded regardless of reality
  /// — computed here from the same live `food_orders` rows `watchOrders`
  /// already streams in for the orders screen, no separate query needed.
  int get ordersToday => [...newOrders, ...prepOrders, ...readyOrders, ...doneOrders].where(_isToday).length;

  double get revenueToday =>
      doneOrders.where(_isToday).fold(0.0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0));

  String get deliveryMethodLabel => switch (deliveryMethod) {
        DeliveryMethod.afrigo => 'عبر مندوبي Afrigo',
        DeliveryMethod.own => 'توصيل خاص بالمطعم',
        DeliveryMethod.pickup => 'استلام فقط (بدون توصيل)',
      };

  FoodFlowState copyWith({
    FoodScreen? screen,
    List<FoodScreen>? hist,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    bool? doc1,
    bool? doc2,
    bool? licenseUploading,
    bool? logoUploaded,
    bool? logoUploading,
    Object? pickedLat = _unset,
    Object? pickedLng = _unset,
    Object? pickedAddress = _unset,
    bool? open,
    bool? lowBalanceDemo,
    Object? balance = _unset,
    Object? walletId = _unset,
    List<Map<String, dynamic>>? walletTransactions,
    Object? restaurantId = _unset,
    Object? restaurantName = _unset,
    Object? restaurantLogoUrl = _unset,
    Object? restaurantCuisineType = _unset,
    Object? restaurantStatus = _unset,
    Object? restaurantRejectionReason = _unset,
    List<DishCategory>? categories,
    List<Dish>? dishes,
    bool? menuLoading,
    bool? addDishOpen,
    DeliveryMethod? deliveryMethod,
    String? deliveryFee,
    String? minOrder,
    String? prepTime,
    OrderTab? orderTab,
    List<Map<String, dynamic>>? newOrders,
    List<Map<String, dynamic>>? prepOrders,
    List<Map<String, dynamic>>? readyOrders,
    List<Map<String, dynamic>>? doneOrders,
    Object? selectedOrderId = _unset,
    Object? commissionPct = _unset,
    List<Map<String, dynamic>>? workingHours,
    bool? isSubmitting,
    Object? authError = _unset,
    Object? actionError = _unset,
  }) {
    return FoodFlowState(
      screen: screen ?? this.screen,
      hist: hist ?? this.hist,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      doc1: doc1 ?? this.doc1,
      doc2: doc2 ?? this.doc2,
      licenseUploading: licenseUploading ?? this.licenseUploading,
      logoUploaded: logoUploaded ?? this.logoUploaded,
      logoUploading: logoUploading ?? this.logoUploading,
      pickedLat: identical(pickedLat, _unset) ? this.pickedLat : pickedLat as double?,
      pickedLng: identical(pickedLng, _unset) ? this.pickedLng : pickedLng as double?,
      pickedAddress: identical(pickedAddress, _unset) ? this.pickedAddress : pickedAddress as String?,
      open: open ?? this.open,
      lowBalanceDemo: lowBalanceDemo ?? this.lowBalanceDemo,
      balance: identical(balance, _unset) ? this.balance : balance as double?,
      walletId: identical(walletId, _unset) ? this.walletId : walletId as String?,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      restaurantId: identical(restaurantId, _unset) ? this.restaurantId : restaurantId as String?,
      restaurantName: identical(restaurantName, _unset) ? this.restaurantName : restaurantName as String?,
      restaurantLogoUrl: identical(restaurantLogoUrl, _unset) ? this.restaurantLogoUrl : restaurantLogoUrl as String?,
      restaurantCuisineType: identical(restaurantCuisineType, _unset) ? this.restaurantCuisineType : restaurantCuisineType as String?,
      restaurantStatus: identical(restaurantStatus, _unset) ? this.restaurantStatus : restaurantStatus as String?,
      restaurantRejectionReason: identical(restaurantRejectionReason, _unset)
          ? this.restaurantRejectionReason
          : restaurantRejectionReason as String?,
      categories: categories ?? this.categories,
      dishes: dishes ?? this.dishes,
      menuLoading: menuLoading ?? this.menuLoading,
      addDishOpen: addDishOpen ?? this.addDishOpen,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrder: minOrder ?? this.minOrder,
      prepTime: prepTime ?? this.prepTime,
      orderTab: orderTab ?? this.orderTab,
      newOrders: newOrders ?? this.newOrders,
      prepOrders: prepOrders ?? this.prepOrders,
      readyOrders: readyOrders ?? this.readyOrders,
      doneOrders: doneOrders ?? this.doneOrders,
      selectedOrderId: identical(selectedOrderId, _unset) ? this.selectedOrderId : selectedOrderId as String?,
      commissionPct: identical(commissionPct, _unset) ? this.commissionPct : commissionPct as double?,
      workingHours: workingHours ?? this.workingHours,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authError: identical(authError, _unset) ? this.authError : authError as String?,
      actionError: identical(actionError, _unset) ? this.actionError : actionError as String?,
    );
  }
}

const _unset = Object();
