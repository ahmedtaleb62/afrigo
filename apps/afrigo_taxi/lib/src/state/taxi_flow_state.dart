import 'taxi_screen.dart';

/// A real incoming ride offer received via Realtime Broadcast from
/// `request-ride` (channel `driver:{uid}:incoming_orders`, event
/// `incoming_ride`). Fields match that payload exactly.
class IncomingRideOffer {
  const IncomingRideOffer({
    required this.rideId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distanceKm,
    required this.price,
  });

  factory IncomingRideOffer.fromPayload(Map<String, dynamic> payload) => IncomingRideOffer(
        rideId: payload['ride_id'] as String,
        pickupAddress: payload['pickup_address'] as String? ?? '',
        pickupLat: (payload['pickup_lat'] as num?)?.toDouble() ?? 18.0858,
        pickupLng: (payload['pickup_lng'] as num?)?.toDouble() ?? -15.9785,
        dropoffAddress: payload['dropoff_address'] as String? ?? '',
        dropoffLat: (payload['dropoff_lat'] as num?)?.toDouble() ?? 18.0858,
        dropoffLng: (payload['dropoff_lng'] as num?)?.toDouble() ?? -15.9785,
        distanceKm: (payload['distance_km'] as num?)?.toDouble() ?? 0,
        price: (payload['price'] as num?)?.toDouble() ?? 0,
      );

  final String rideId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final double distanceKm;
  final double price;
}

/// The full `rides` row for the trip currently in progress, fetched once
/// right after `respond-to-order` accepts it (the broadcast payload alone
/// doesn't carry `duration_min`/`client_id`).
class ActiveRide {
  const ActiveRide({
    required this.id,
    required this.clientId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distanceKm,
    required this.durationMin,
    required this.price,
    required this.status,
  });

  factory ActiveRide.fromRow(Map<String, dynamic> row) => ActiveRide(
        id: row['id'] as String,
        clientId: row['client_id'] as String,
        pickupAddress: row['pickup_address'] as String? ?? '',
        pickupLat: (row['pickup_lat'] as num?)?.toDouble() ?? 18.0858,
        pickupLng: (row['pickup_lng'] as num?)?.toDouble() ?? -15.9785,
        dropoffAddress: row['dropoff_address'] as String? ?? '',
        dropoffLat: (row['dropoff_lat'] as num?)?.toDouble() ?? 18.0858,
        dropoffLng: (row['dropoff_lng'] as num?)?.toDouble() ?? -15.9785,
        distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0,
        durationMin: (row['duration_min'] as num?)?.toDouble() ?? 0,
        price: (row['price'] as num?)?.toDouble() ?? 0,
        status: row['status'] as String? ?? 'accepted',
      );

  final String id;
  final String clientId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final double distanceKm;
  final double durationMin;
  final double price;
  final String status;

  ActiveRide copyWith({String? status}) => ActiveRide(
        id: id,
        clientId: clientId,
        pickupAddress: pickupAddress,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffAddress: dropoffAddress,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        distanceKm: distanceKm,
        durationMin: durationMin,
        price: price,
        status: status ?? this.status,
      );
}

class TaxiFlowState {
  const TaxiFlowState({
    this.screen = TaxiScreen.splash,
    this.hist = const [],
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.otp = const ['', '', '', '', '', ''],
    this.otpCountdown = 45,
    this.licensePhoto = false,
    this.licenseUploading = false,
    this.online = false,
    this.balance,
    this.walletLoaded = false,
    this.walletId,
    this.walletTransactions = const [],
    this.walletTransactionsLoading = false,
    this.tripHistory = const [],
    this.tripHistoryLoading = false,
    this.notifications = const [],
    this.notificationsLoading = false,
    this.vehicleStatus,
    this.vehicleRejectionReason,
    this.incomingRide,
    this.incomingCountdown = 20,
    this.activeRide,
    this.clientName,
    this.clientPhone,
    this.commissionPct,
    this.custRating = 0,
    this.isSubmitting = false,
    this.authError,
    this.actionError,
    this.currentLat,
    this.currentLng,
    this.platformSettings = const {},
  });

  final TaxiScreen screen;
  final List<TaxiScreen> hist;

  /// Local 8-digit Mauritanian mobile number, no country code (e.g.
  /// `"46123456"`) — `+222` is prefixed only when calling Supabase Auth.
  final String phone;
  final String password;
  final String confirmPassword;
  final String fullName;

  /// 6 digits to match Supabase Auth's `sms_otp_length` (the code
  /// Chinguisoft actually texts is whatever GoTrue generates, relayed as-is
  /// by the `sms-hook` Edge Function — see its doc comment).
  final List<String> otp;
  final int otpCountdown;

  final bool licensePhoto;
  final bool licenseUploading;

  final bool online;

  /// Real balance from `wallets.balance` once loaded (null until then — see
  /// `watchWallet()`). Falls back to 0 rather than any invented number —
  /// `register-provider` always creates the wallet row at signup, so this
  /// null case is just "hasn't loaded yet", not "no wallet exists".
  final double? balance;
  final bool walletLoaded;
  final String? walletId;

  /// Real `wallet_transactions` rows for this driver's wallet (Wallet
  /// screen's "سجل الحركات") — replaces the design's 2 hardcoded demo rows.
  final List<Map<String, dynamic>> walletTransactions;
  final bool walletTransactionsLoading;

  /// Real `rides` rows for this driver (Trip History screen, and the Home
  /// screen's "رحلات اليوم"/"أرباح اليوم" cards, derived from the subset
  /// completed today) — replaces the design's 2 hardcoded demo trips /
  /// fixed 7-trips-2,340-أوقية stat cards.
  final List<Map<String, dynamic>> tripHistory;
  final bool tripHistoryLoading;
  final List<Map<String, dynamic>> notifications;
  final bool notificationsLoading;

  /// Real-time status of the vehicle just submitted for review, watched via
  /// Supabase Realtime on the `vehicles` row (screens 49/50).
  final String? vehicleStatus;
  final String? vehicleRejectionReason;

  /// Non-null while the incoming-ride bottom sheet (screen 51/52) is
  /// showing a real offer received over Realtime Broadcast.
  final IncomingRideOffer? incomingRide;
  final int incomingCountdown;

  /// The trip currently being driven (accepted -> driver_arriving ->
  /// in_progress -> completed), once `respond-to-order` accepts an offer.
  final ActiveRide? activeRide;
  final String? clientName;
  final String? clientPhone;

  /// `commission_settings.percentage` for `taxi`, fetched once for the
  /// trip-end summary breakdown (screen 57) — display only; the real
  /// deduction happens server-side via a DB trigger on ride completion.
  final double? commissionPct;

  final int custRating;

  final bool isSubmitting;
  final String? authError;

  /// Surfaced from a failed `respond-to-order`/`update-order-status` call
  /// (e.g. "another driver already accepted this ride") — screens read this
  /// to show a toast, then the caller should clear it back to null.
  final String? actionError;

  /// Real device GPS fix (via `geolocator`) — the driver's own live position
  /// shown on the home/pickup/trip maps. Falls back to a fixed
  /// Nouakchott-center placeholder everywhere it's used until a fix lands.
  final double? currentLat;
  final double? currentLng;

  /// Raw `platform_settings` key→value map (support phone, legal text —
  /// admin-editable, no app release needed to change). Empty until
  /// `loadPlatformSettings()` runs (after login).
  final Map<String, dynamic> platformSettings;
  String get supportPhone => (platformSettings['support_phone'] as String?)?.trim().isNotEmpty == true ? platformSettings['support_phone'] as String : '+22245000000';
  String get aboutText => (platformSettings['about_ar'] as String?) ?? '';
  String get termsText => (platformSettings['terms_and_conditions_ar'] as String?) ?? '';
  String get privacyText => (platformSettings['privacy_policy_ar'] as String?) ?? '';

  double get resolvedBalance => balance ?? 0;
  bool get lowBalance => resolvedBalance <= 0;

  TaxiFlowState copyWith({
    TaxiScreen? screen,
    List<TaxiScreen>? hist,
    String? phone,
    String? password,
    String? confirmPassword,
    String? fullName,
    List<String>? otp,
    int? otpCountdown,
    bool? licensePhoto,
    bool? licenseUploading,
    bool? online,
    Object? balance = _unset,
    bool? walletLoaded,
    Object? walletId = _unset,
    List<Map<String, dynamic>>? walletTransactions,
    bool? walletTransactionsLoading,
    List<Map<String, dynamic>>? tripHistory,
    bool? tripHistoryLoading,
    List<Map<String, dynamic>>? notifications,
    bool? notificationsLoading,
    Object? vehicleStatus = _unset,
    Object? vehicleRejectionReason = _unset,
    Object? incomingRide = _unset,
    int? incomingCountdown,
    Object? activeRide = _unset,
    Object? clientName = _unset,
    Object? clientPhone = _unset,
    Object? commissionPct = _unset,
    int? custRating,
    bool? isSubmitting,
    Object? authError = _unset,
    Object? actionError = _unset,
    Object? currentLat = _unset,
    Object? currentLng = _unset,
    Map<String, dynamic>? platformSettings,
  }) {
    return TaxiFlowState(
      screen: screen ?? this.screen,
      hist: hist ?? this.hist,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      otp: otp ?? this.otp,
      otpCountdown: otpCountdown ?? this.otpCountdown,
      licensePhoto: licensePhoto ?? this.licensePhoto,
      licenseUploading: licenseUploading ?? this.licenseUploading,
      online: online ?? this.online,
      balance: identical(balance, _unset) ? this.balance : balance as double?,
      walletLoaded: walletLoaded ?? this.walletLoaded,
      walletId: identical(walletId, _unset) ? this.walletId : walletId as String?,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      walletTransactionsLoading: walletTransactionsLoading ?? this.walletTransactionsLoading,
      tripHistory: tripHistory ?? this.tripHistory,
      tripHistoryLoading: tripHistoryLoading ?? this.tripHistoryLoading,
      notifications: notifications ?? this.notifications,
      notificationsLoading: notificationsLoading ?? this.notificationsLoading,
      vehicleStatus: identical(vehicleStatus, _unset) ? this.vehicleStatus : vehicleStatus as String?,
      vehicleRejectionReason:
          identical(vehicleRejectionReason, _unset) ? this.vehicleRejectionReason : vehicleRejectionReason as String?,
      incomingRide: identical(incomingRide, _unset) ? this.incomingRide : incomingRide as IncomingRideOffer?,
      incomingCountdown: incomingCountdown ?? this.incomingCountdown,
      activeRide: identical(activeRide, _unset) ? this.activeRide : activeRide as ActiveRide?,
      clientName: identical(clientName, _unset) ? this.clientName : clientName as String?,
      clientPhone: identical(clientPhone, _unset) ? this.clientPhone : clientPhone as String?,
      commissionPct: identical(commissionPct, _unset) ? this.commissionPct : commissionPct as double?,
      custRating: custRating ?? this.custRating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authError: identical(authError, _unset) ? this.authError : authError as String?,
      actionError: identical(actionError, _unset) ? this.actionError : actionError as String?,
      currentLat: identical(currentLat, _unset) ? this.currentLat : currentLat as double?,
      currentLng: identical(currentLng, _unset) ? this.currentLng : currentLng as double?,
      platformSettings: platformSettings ?? this.platformSettings,
    );
  }
}

const _unset = Object();
