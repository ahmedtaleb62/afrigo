import 'livreur_screen.dart';

/// The two possible sources of a delivery leg: a standalone parcel request
/// (`delivery_requests` table) or the second leg of a food order
/// (`food_orders` reaching `ready`/`searching_livreur`). Both arrive on the
/// same Realtime channel (`delivery:{uid}:incoming_orders`) but on
/// different broadcast events, and are claimed via `respond-to-order` with
/// a different `order_type`.
enum DeliveryOrderType { deliveryRequest, foodOrder }

class IncomingDeliveryOffer {
  const IncomingDeliveryOffer({
    required this.orderType,
    required this.orderId,
    required this.pickupLabel,
    required this.dropoffLabel,
    this.distanceKm,
    this.price,
  });

  final DeliveryOrderType orderType;
  final String orderId;
  final String pickupLabel;
  final String dropoffLabel;
  final double? distanceKm;
  final double? price;
}

/// The delivery leg currently being driven, once claimed via
/// `respond-to-order`. `status` mirrors the row's real Postgres status
/// (`delivery_status` for parcels, `food_order_status` for the food leg).
class ActiveDelivery {
  const ActiveDelivery({
    required this.orderType,
    required this.orderId,
    required this.clientId,
    required this.pickupLabel,
    required this.dropoffLabel,
    required this.price,
    required this.status,
    this.distanceKm,
    this.recipientName,
    this.recipientPhone,
  });

  final DeliveryOrderType orderType;
  final String orderId;
  final String clientId;
  final String pickupLabel;
  final String dropoffLabel;
  final double price;
  final String status;
  final double? distanceKm;
  final String? recipientName;
  final String? recipientPhone;

  ActiveDelivery copyWith({String? status}) => ActiveDelivery(
        orderType: orderType,
        orderId: orderId,
        clientId: clientId,
        pickupLabel: pickupLabel,
        dropoffLabel: dropoffLabel,
        price: price,
        status: status ?? this.status,
        distanceKm: distanceKm,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
      );
}

class LivreurFlowState {
  const LivreurFlowState({
    this.screen = LivreurScreen.splash,
    this.hist = const [],
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.licensePhoto = false,
    this.online = false,
    this.lowBalanceDemo = false,
    this.balance,
    this.vehicleStatus,
    this.vehicleRejectionReason,
    this.incomingOffer,
    this.incomingCountdown = 20,
    this.activeDelivery,
    this.commissionPct,
    this.custRating = 0,
    this.isSubmitting = false,
    this.authError,
    this.actionError,
  });

  final LivreurScreen screen;
  final List<LivreurScreen> hist;

  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final bool licensePhoto;

  final bool online;
  final bool lowBalanceDemo;
  final double? balance;

  final String? vehicleStatus;
  final String? vehicleRejectionReason;

  final IncomingDeliveryOffer? incomingOffer;
  final int incomingCountdown;

  final ActiveDelivery? activeDelivery;

  /// `commission_settings.percentage` for the active delivery's service
  /// (`delivery` or `food`) — display only, fetched once the leg's type is
  /// known; the real deduction is a DB trigger on completion.
  final double? commissionPct;

  final int custRating;

  final bool isSubmitting;
  final String? authError;
  final String? actionError;

  double get resolvedBalance => balance ?? 410;
  bool get lowBalance => lowBalanceDemo || resolvedBalance <= 0;

  LivreurFlowState copyWith({
    LivreurScreen? screen,
    List<LivreurScreen>? hist,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    bool? licensePhoto,
    bool? online,
    bool? lowBalanceDemo,
    Object? balance = _unset,
    Object? vehicleStatus = _unset,
    Object? vehicleRejectionReason = _unset,
    Object? incomingOffer = _unset,
    int? incomingCountdown,
    Object? activeDelivery = _unset,
    Object? commissionPct = _unset,
    int? custRating,
    bool? isSubmitting,
    Object? authError = _unset,
    Object? actionError = _unset,
  }) {
    return LivreurFlowState(
      screen: screen ?? this.screen,
      hist: hist ?? this.hist,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      licensePhoto: licensePhoto ?? this.licensePhoto,
      online: online ?? this.online,
      lowBalanceDemo: lowBalanceDemo ?? this.lowBalanceDemo,
      balance: identical(balance, _unset) ? this.balance : balance as double?,
      vehicleStatus: identical(vehicleStatus, _unset) ? this.vehicleStatus : vehicleStatus as String?,
      vehicleRejectionReason:
          identical(vehicleRejectionReason, _unset) ? this.vehicleRejectionReason : vehicleRejectionReason as String?,
      incomingOffer: identical(incomingOffer, _unset) ? this.incomingOffer : incomingOffer as IncomingDeliveryOffer?,
      incomingCountdown: incomingCountdown ?? this.incomingCountdown,
      activeDelivery: identical(activeDelivery, _unset) ? this.activeDelivery : activeDelivery as ActiveDelivery?,
      commissionPct: identical(commissionPct, _unset) ? this.commissionPct : commissionPct as double?,
      custRating: custRating ?? this.custRating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authError: identical(authError, _unset) ? this.authError : authError as String?,
      actionError: identical(actionError, _unset) ? this.actionError : actionError as String?,
    );
  }
}

const _unset = Object();
