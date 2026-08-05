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
    this.open = false,
    this.lowBalanceDemo = false,
    this.balance,
    this.restaurantId,
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

  final bool open;
  final bool lowBalanceDemo;
  final double? balance;

  final String? restaurantId;
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

  double get resolvedBalance => balance ?? 620;
  bool get lowBalance => lowBalanceDemo || resolvedBalance <= 0;

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
    bool? open,
    bool? lowBalanceDemo,
    Object? balance = _unset,
    Object? restaurantId = _unset,
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
      open: open ?? this.open,
      lowBalanceDemo: lowBalanceDemo ?? this.lowBalanceDemo,
      balance: identical(balance, _unset) ? this.balance : balance as double?,
      restaurantId: identical(restaurantId, _unset) ? this.restaurantId : restaurantId as String?,
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
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authError: identical(authError, _unset) ? this.authError : authError as String?,
      actionError: identical(actionError, _unset) ? this.actionError : actionError as String?,
    );
  }
}

const _unset = Object();
