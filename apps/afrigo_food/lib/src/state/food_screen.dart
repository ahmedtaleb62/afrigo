/// Every screen in the Food app (screens 61-72 of the design). Mirrors the
/// `screen` field of the original design prototype's state machine 1:1.
enum FoodScreen {
  splash,
  login,
  signup,
  otp,
  restaurantDocs,
  bikeDocs,
  pendingApproval,
  rejected,
  home,
  menu,
  deliverySettings,
  orders,
  orderDetail,
  wallet,
  reports,
  profile,
  workingHours,
}

enum OrderTab { newOrder, prep, ready, done }

enum DeliveryMethod { afrigo, own, pickup }
