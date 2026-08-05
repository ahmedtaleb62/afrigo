/// Every screen in the Client app (screens 1-44 of the design). Mirrors the
/// `screen` field of the original design prototype's state machine 1:1.
enum ClientScreen {
  splash,
  langSelect,
  onboarding,
  login,
  signup,
  otp,
  forgot,
  locationPermission,
  notifPermission,
  home,

  rideOrigin,
  rideDestination,
  rideConfirm,
  searching,
  noProvider,
  providerFound,
  tracking,
  tripEnd,
  tripRating,

  foodList,
  restaurantDetail,
  dishDetail,
  cart,
  foodCheckout,
  foodDeliveryAddress,
  foodWaiting,
  foodRejected,
  foodTracking,
  foodRating,

  parcelPickup,
  parcelDropoff,
  parcelDetails,
  parcelConfirm,

  voiceRecord,
  voiceAnalyzing,
  voiceConfirm,
  voiceFail,

  orderHistory,
  profile,
  settings,
  notificationsList,
  support,
}

/// `flowType` in the original design — which service the searching/tracking
/// screens are currently narrating (`رحلة تكسي` vs `توصيل طرد`).
enum ClientFlowType { taxi, delivery }

enum FoodStage { waiting, accepted, preparing, ready, onway, delivered }

enum VoiceStage { idle, recording }

enum OrderTab { active, past }
