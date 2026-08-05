import 'cart_item.dart';
import 'client_screen.dart';

class ClientFlowState {
  const ClientFlowState({
    this.screen = ClientScreen.splash,
    this.hist = const [],
    this.langPick,
    this.onboardStep = 0,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.showPass = false,
    this.otp = const ['', '', '', ''],
    this.otpCountdown = 45,
    this.forgotStep = 0,
    this.fpEmail = '',
    this.fpCode = '',
    this.fpNewPassword = '',
    this.currentLat,
    this.currentLng,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.pickupIsUserSet = false,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffAddress,
    this.flowType = ClientFlowType.taxi,
    this.rideDest = '',
    this.rideVehicle = 'اقتصادي',
    this.paymentMethod = 'cash',
    this.orderNote = '',
    this.ratingStars = 0,
    this.restaurants = const [],
    this.restaurantsLoading = false,
    this.restaurantSearch = '',
    this.restaurantFilter = 'all',
    this.selectedRestaurantId,
    this.selectedRestaurantName,
    this.restaurantDishes = const [],
    this.selectedDish,
    this.dishQty = 1,
    this.cart = const [],
    this.foodStage = FoodStage.waiting,
    this.foodRatingRestaurant = 0,
    this.foodRatingDelivery = 0,
    this.foodOrderId,
    this.foodOrderTotal,
    this.parcelType = 'وثائق',
    this.parcelPhoto = false,
    this.recipientName = '',
    this.recipientPhone = '',
    this.parcelNotes = '',
    this.voiceStage = VoiceStage.idle,
    this.voiceTranscript = '',
    this.orderTab = OrderTab.active,
    this.notifEnabled = true,
    this.settingsLang = 'ar',
    this.isSubmitting = false,
    this.authError,
    this.activeOrderId,
    this.activeOrderStatus,
    this.orderDistanceKm,
    this.orderDurationMin,
    this.orderPrice,
    this.providerId,
    this.providerName,
    this.providerPhone,
    this.providerVehicle,
    this.requestError,
    this.livreurId,
    this.profileFullName,
    this.profileEmail,
    this.profilePhone,
    this.profileLoading = false,
    this.notifications = const [],
    this.notificationsLoading = false,
    this.orderHistory = const [],
    this.orderHistoryLoading = false,
    this.savedAddresses = const [],
    this.savedAddressesLoading = false,
    this.platformSettings = const {},
    this.fareEstimateDistanceKm,
    this.fareEstimateDurationMin,
    this.fareEstimatePrice,
    this.fareEstimateLoading = false,
    this.driverLat,
    this.driverLng,
  });

  final ClientScreen screen;
  final List<ClientScreen> hist;

  final String? langPick;
  final int onboardStep;

  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final bool showPass;

  final List<String> otp;
  final int otpCountdown;

  final int forgotStep;
  final String fpEmail;
  final String fpCode;
  final String fpNewPassword;

  /// Real device GPS fix (via `geolocator`), once granted + fetched — falls
  /// back to the fixed Algiers-center placeholder everywhere it's used
  /// until then (see `ClientFlowController` doc comment).
  final double? currentLat;
  final double? currentLng;

  /// Real pickup/dropoff coordinates once picked on a real map
  /// (`LocationPickerMap`) or resolved via geocoding a typed search —
  /// replaces the old always-placeholder pair when set.
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;

  /// True once the user has deliberately moved the pickup pin (dragged the
  /// map or tapped "use my location") — until then, `pickupLat`/`Lng` are
  /// just a live mirror of `currentLat`/`Lng` (see `RideOriginScreen`), so a
  /// GPS fix landing after the picker already auto-resolved once (e.g. from
  /// the placeholder) still overrides it instead of freezing the pickup at
  /// the wrong point forever — which was silently sending the wrong pickup
  /// coordinates to `request-ride`'s driver matching (always "no driver
  /// found" if no one happened to be online within 3km of the placeholder).
  final bool pickupIsUserSet;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffAddress;

  final ClientFlowType flowType;
  final String rideDest;
  final String rideVehicle;

  /// 'cash' / 'baridimob' / 'bank_transfer' — see `payment_method_field.dart`.
  final String paymentMethod;

  /// The ride/parcel "ملاحظة للسائق" field — `rides.client_note` also backs
  /// food orders' own note, `food_orders.client_note`.
  final String orderNote;

  final int ratingStars;

  /// Real `restaurants` rows (verified + open), and once one is picked, its
  /// real `restaurant_dishes` rows — replacing the design's single
  /// hardcoded demo restaurant/menu.
  final List<Map<String, dynamic>> restaurants;
  final bool restaurantsLoading;

  /// Free-text match against name/cuisine, and one of: all / rating /
  /// nearest / price_low / price_high / open / closed — see
  /// `food_list_screen.dart`.
  final String restaurantSearch;
  final String restaurantFilter;
  final String? selectedRestaurantId;
  final String? selectedRestaurantName;
  final List<Map<String, dynamic>> restaurantDishes;
  final Map<String, dynamic>? selectedDish;
  final int dishQty;
  final List<CartItem> cart;

  final FoodStage foodStage;
  final int foodRatingRestaurant;
  final int foodRatingDelivery;

  /// The real `food_orders` row this cart turned into, once
  /// `request-food-order` succeeds — watched live via Realtime.
  final String? foodOrderId;
  final double? foodOrderTotal;

  final String parcelType;
  final bool parcelPhoto;
  final String recipientName;
  final String recipientPhone;
  final String parcelNotes;

  final VoiceStage voiceStage;
  final String voiceTranscript;

  final OrderTab orderTab;
  final bool notifEnabled;
  final String settingsLang;

  /// Not in the original prototype (which never calls a real backend) —
  /// added because real Supabase Auth calls are actually async and can fail.
  final bool isSubmitting;
  final String? authError;

  /// The real `rides`/`delivery_requests` row this request turned into,
  /// once `request-ride`/`request-delivery` succeeds — watched live via
  /// Realtime (see `ClientFlowController._subscribeOrderTracking`).
  final String? activeOrderId;
  final String? activeOrderStatus;
  final double? orderDistanceKm;
  final double? orderDurationMin;
  final double? orderPrice;

  /// Assigned driver/livreur's user id (read straight off the `rides`/
  /// `delivery_requests` row once accepted — needed for the rating insert's
  /// `rated_entity_id`) plus contact + vehicle info, fetched via the
  /// `get_order_counterpart` RPC.
  final String? providerId;
  final String? providerName;
  final String? providerPhone;
  final String? providerVehicle;

  /// Surfaced from a failed request/response-to-order call — screens read
  /// this to show a toast, then the caller should clear it back to null.
  final String? requestError;

  /// The livreur's own user id for the current food order, read straight
  /// off the `food_orders` row once assigned — `providerId` above is reused
  /// for ride/delivery driver ids, but food orders need a separate slot
  /// since `finishFoodRating` rates the restaurant and the livreur
  /// separately.
  final String? livreurId;

  /// Real `profiles` row for the logged-in user — replaces the design's
  /// hardcoded "سارة بن علي" demo profile. Null until `loadProfile()` runs.
  final String? profileFullName;
  final String? profileEmail;
  final String? profilePhone;
  final bool profileLoading;

  /// Real `notifications` rows for the logged-in user.
  final List<Map<String, dynamic>> notifications;
  final bool notificationsLoading;

  /// Real past orders, merged from `rides`/`food_orders`/`delivery_requests`
  /// — replaces the design's static demo order history.
  final List<Map<String, dynamic>> orderHistory;
  final bool orderHistoryLoading;

  /// Real `saved_addresses` rows (Settings screen).
  final List<Map<String, dynamic>> savedAddresses;
  final bool savedAddressesLoading;

  /// Raw `platform_settings` key→value map (support phone, legal text —
  /// admin-editable, no app release needed to change). Empty until
  /// `loadPlatformSettings()` runs (after login).
  final Map<String, dynamic> platformSettings;
  String get supportPhone => (platformSettings['support_phone'] as String?)?.trim().isNotEmpty == true ? platformSettings['support_phone'] as String : '+22245000000';
  String get aboutText => (platformSettings['about_ar'] as String?) ?? '';
  String get termsText => (platformSettings['terms_and_conditions_ar'] as String?) ?? '';
  String get privacyText => (platformSettings['privacy_policy_ar'] as String?) ?? '';

  /// Client-side fare preview for the confirm screens (ride/parcel) — same
  /// haversine + `pricing_settings` formula the server uses in
  /// `_shared/fare.ts`'s `calculateFare`, computed here so the estimate
  /// reacts live as the picked pickup/dropoff move instead of showing a
  /// fixed placeholder number. The real, authoritative price is still
  /// whatever `calculateFare` computes server-side when the order is
  /// actually placed.
  final double? fareEstimateDistanceKm;
  final double? fareEstimateDurationMin;
  final double? fareEstimatePrice;
  final bool fareEstimateLoading;

  /// The assigned driver/livreur's live position, broadcast directly from
  /// their own app (Realtime Broadcast, not a DB write — see
  /// `_subscribeDriverLocation`) while the order is `accepted`/
  /// `driver_arriving`/`in_progress`. Null until the first ping arrives, so
  /// the tracking screen falls back to the static pickup point until then.
  final double? driverLat;
  final double? driverLng;

  int get cartCount => cart.fold(0, (a, i) => a + i.qty);
  int get cartSubtotal => cart.fold(0, (a, i) => a + i.qty * i.price);
  int get cartGrandTotal => cartSubtotal + 100;

  ClientFlowState copyWith({
    ClientScreen? screen,
    List<ClientScreen>? hist,
    Object? langPick = _unset,
    int? onboardStep,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    bool? showPass,
    List<String>? otp,
    int? otpCountdown,
    int? forgotStep,
    String? fpEmail,
    String? fpCode,
    String? fpNewPassword,
    Object? currentLat = _unset,
    Object? currentLng = _unset,
    Object? pickupLat = _unset,
    Object? pickupLng = _unset,
    Object? pickupAddress = _unset,
    bool? pickupIsUserSet,
    Object? dropoffLat = _unset,
    Object? dropoffLng = _unset,
    Object? dropoffAddress = _unset,
    ClientFlowType? flowType,
    String? rideDest,
    String? rideVehicle,
    String? paymentMethod,
    String? orderNote,
    int? ratingStars,
    List<Map<String, dynamic>>? restaurants,
    bool? restaurantsLoading,
    String? restaurantSearch,
    String? restaurantFilter,
    Object? selectedRestaurantId = _unset,
    Object? selectedRestaurantName = _unset,
    List<Map<String, dynamic>>? restaurantDishes,
    Object? selectedDish = _unset,
    int? dishQty,
    List<CartItem>? cart,
    FoodStage? foodStage,
    int? foodRatingRestaurant,
    int? foodRatingDelivery,
    Object? foodOrderId = _unset,
    Object? foodOrderTotal = _unset,
    String? parcelType,
    bool? parcelPhoto,
    String? recipientName,
    String? recipientPhone,
    String? parcelNotes,
    VoiceStage? voiceStage,
    String? voiceTranscript,
    OrderTab? orderTab,
    bool? notifEnabled,
    String? settingsLang,
    bool? isSubmitting,
    Object? authError = _unset,
    Object? activeOrderId = _unset,
    Object? activeOrderStatus = _unset,
    Object? orderDistanceKm = _unset,
    Object? orderDurationMin = _unset,
    Object? orderPrice = _unset,
    Object? providerId = _unset,
    Object? providerName = _unset,
    Object? providerPhone = _unset,
    Object? providerVehicle = _unset,
    Object? requestError = _unset,
    Object? livreurId = _unset,
    Object? profileFullName = _unset,
    Object? profileEmail = _unset,
    Object? profilePhone = _unset,
    bool? profileLoading,
    List<Map<String, dynamic>>? notifications,
    bool? notificationsLoading,
    List<Map<String, dynamic>>? orderHistory,
    bool? orderHistoryLoading,
    List<Map<String, dynamic>>? savedAddresses,
    bool? savedAddressesLoading,
    Map<String, dynamic>? platformSettings,
    Object? fareEstimateDistanceKm = _unset,
    Object? fareEstimateDurationMin = _unset,
    Object? fareEstimatePrice = _unset,
    bool? fareEstimateLoading,
    Object? driverLat = _unset,
    Object? driverLng = _unset,
  }) {
    return ClientFlowState(
      screen: screen ?? this.screen,
      hist: hist ?? this.hist,
      langPick: identical(langPick, _unset) ? this.langPick : langPick as String?,
      onboardStep: onboardStep ?? this.onboardStep,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      showPass: showPass ?? this.showPass,
      otp: otp ?? this.otp,
      otpCountdown: otpCountdown ?? this.otpCountdown,
      forgotStep: forgotStep ?? this.forgotStep,
      fpEmail: fpEmail ?? this.fpEmail,
      fpCode: fpCode ?? this.fpCode,
      fpNewPassword: fpNewPassword ?? this.fpNewPassword,
      currentLat: identical(currentLat, _unset) ? this.currentLat : currentLat as double?,
      currentLng: identical(currentLng, _unset) ? this.currentLng : currentLng as double?,
      pickupLat: identical(pickupLat, _unset) ? this.pickupLat : pickupLat as double?,
      pickupLng: identical(pickupLng, _unset) ? this.pickupLng : pickupLng as double?,
      pickupAddress: identical(pickupAddress, _unset) ? this.pickupAddress : pickupAddress as String?,
      pickupIsUserSet: pickupIsUserSet ?? this.pickupIsUserSet,
      dropoffLat: identical(dropoffLat, _unset) ? this.dropoffLat : dropoffLat as double?,
      dropoffLng: identical(dropoffLng, _unset) ? this.dropoffLng : dropoffLng as double?,
      dropoffAddress: identical(dropoffAddress, _unset) ? this.dropoffAddress : dropoffAddress as String?,
      flowType: flowType ?? this.flowType,
      rideDest: rideDest ?? this.rideDest,
      rideVehicle: rideVehicle ?? this.rideVehicle,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderNote: orderNote ?? this.orderNote,
      ratingStars: ratingStars ?? this.ratingStars,
      restaurants: restaurants ?? this.restaurants,
      restaurantsLoading: restaurantsLoading ?? this.restaurantsLoading,
      restaurantSearch: restaurantSearch ?? this.restaurantSearch,
      restaurantFilter: restaurantFilter ?? this.restaurantFilter,
      selectedRestaurantId: identical(selectedRestaurantId, _unset) ? this.selectedRestaurantId : selectedRestaurantId as String?,
      selectedRestaurantName:
          identical(selectedRestaurantName, _unset) ? this.selectedRestaurantName : selectedRestaurantName as String?,
      restaurantDishes: restaurantDishes ?? this.restaurantDishes,
      selectedDish: identical(selectedDish, _unset) ? this.selectedDish : selectedDish as Map<String, dynamic>?,
      dishQty: dishQty ?? this.dishQty,
      cart: cart ?? this.cart,
      foodStage: foodStage ?? this.foodStage,
      foodRatingRestaurant: foodRatingRestaurant ?? this.foodRatingRestaurant,
      foodRatingDelivery: foodRatingDelivery ?? this.foodRatingDelivery,
      foodOrderId: identical(foodOrderId, _unset) ? this.foodOrderId : foodOrderId as String?,
      foodOrderTotal: identical(foodOrderTotal, _unset) ? this.foodOrderTotal : foodOrderTotal as double?,
      parcelType: parcelType ?? this.parcelType,
      parcelPhoto: parcelPhoto ?? this.parcelPhoto,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      parcelNotes: parcelNotes ?? this.parcelNotes,
      voiceStage: voiceStage ?? this.voiceStage,
      voiceTranscript: voiceTranscript ?? this.voiceTranscript,
      orderTab: orderTab ?? this.orderTab,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      settingsLang: settingsLang ?? this.settingsLang,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authError: identical(authError, _unset) ? this.authError : authError as String?,
      activeOrderId: identical(activeOrderId, _unset) ? this.activeOrderId : activeOrderId as String?,
      activeOrderStatus: identical(activeOrderStatus, _unset) ? this.activeOrderStatus : activeOrderStatus as String?,
      orderDistanceKm: identical(orderDistanceKm, _unset) ? this.orderDistanceKm : orderDistanceKm as double?,
      orderDurationMin: identical(orderDurationMin, _unset) ? this.orderDurationMin : orderDurationMin as double?,
      orderPrice: identical(orderPrice, _unset) ? this.orderPrice : orderPrice as double?,
      providerId: identical(providerId, _unset) ? this.providerId : providerId as String?,
      providerName: identical(providerName, _unset) ? this.providerName : providerName as String?,
      providerPhone: identical(providerPhone, _unset) ? this.providerPhone : providerPhone as String?,
      providerVehicle: identical(providerVehicle, _unset) ? this.providerVehicle : providerVehicle as String?,
      requestError: identical(requestError, _unset) ? this.requestError : requestError as String?,
      livreurId: identical(livreurId, _unset) ? this.livreurId : livreurId as String?,
      profileFullName: identical(profileFullName, _unset) ? this.profileFullName : profileFullName as String?,
      profileEmail: identical(profileEmail, _unset) ? this.profileEmail : profileEmail as String?,
      profilePhone: identical(profilePhone, _unset) ? this.profilePhone : profilePhone as String?,
      profileLoading: profileLoading ?? this.profileLoading,
      notifications: notifications ?? this.notifications,
      notificationsLoading: notificationsLoading ?? this.notificationsLoading,
      orderHistory: orderHistory ?? this.orderHistory,
      orderHistoryLoading: orderHistoryLoading ?? this.orderHistoryLoading,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedAddressesLoading: savedAddressesLoading ?? this.savedAddressesLoading,
      platformSettings: platformSettings ?? this.platformSettings,
      fareEstimateDistanceKm: identical(fareEstimateDistanceKm, _unset) ? this.fareEstimateDistanceKm : fareEstimateDistanceKm as double?,
      fareEstimateDurationMin: identical(fareEstimateDurationMin, _unset) ? this.fareEstimateDurationMin : fareEstimateDurationMin as double?,
      fareEstimatePrice: identical(fareEstimatePrice, _unset) ? this.fareEstimatePrice : fareEstimatePrice as double?,
      fareEstimateLoading: fareEstimateLoading ?? this.fareEstimateLoading,
      driverLat: identical(driverLat, _unset) ? this.driverLat : driverLat as double?,
      driverLng: identical(driverLng, _unset) ? this.driverLng : driverLng as double?,
    );
  }
}

const _unset = Object();
