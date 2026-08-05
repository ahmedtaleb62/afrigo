/// Every screen in the Taxi app (screens 45-60 of the design). Mirrors the
/// `screen` field of the original design prototype's state machine 1:1.
enum TaxiScreen {
  splash,
  login,
  signup,
  otp,
  accountCreating,
  vehicleDocs,
  pendingApproval,
  rejected,
  home,
  wallet,
  navigateToPickup,
  tripOngoing,
  tripEndSummary,
  rateCustomer,
  tripHistory,
  profile,
  notificationsList,
}
