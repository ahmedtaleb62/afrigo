import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/food/cart_screen.dart';
import 'screens/food/dish_detail_screen.dart';
import 'screens/food/food_checkout_screen.dart';
import 'screens/food/food_delivery_address_screen.dart';
import 'screens/food/food_list_screen.dart';
import 'screens/food/food_rating_screen.dart';
import 'screens/food/food_rejected_screen.dart';
import 'screens/food/food_tracking_screen.dart';
import 'screens/food/food_waiting_screen.dart';
import 'screens/food/restaurant_detail_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lang_select_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notif_permission_screen.dart';
import 'screens/notifications_list_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/parcel/parcel_confirm_screen.dart';
import 'screens/parcel/parcel_details_screen.dart';
import 'screens/parcel/parcel_dropoff_screen.dart';
import 'screens/parcel/parcel_pickup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ride/no_provider_screen.dart';
import 'screens/ride/provider_found_screen.dart';
import 'screens/ride/ride_confirm_screen.dart';
import 'screens/ride/ride_destination_screen.dart';
import 'screens/ride/ride_origin_screen.dart';
import 'screens/ride/searching_screen.dart';
import 'screens/ride/tracking_screen.dart';
import 'screens/ride/trip_end_screen.dart';
import 'screens/ride/trip_rating_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/support_screen.dart';
import 'screens/voice/voice_analyzing_screen.dart';
import 'screens/voice/voice_confirm_screen.dart';
import 'screens/voice/voice_fail_screen.dart';
import 'screens/voice/voice_record_screen.dart';
import 'state/client_flow_controller.dart';
import 'state/client_screen.dart';

/// Renders whichever screen `ClientFlowController.state.screen` points at.
///
/// The original design wraps every screen in a fake iOS device bezel
/// (`ios-frame.jsx`) purely so the browser-based mock could be previewed —
/// a real Flutter app already gets a real status bar/home indicator from
/// the OS, so that chrome isn't ported; each screen's own ~54-60px top
/// padding (copied verbatim from the design) stands in for it.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(clientFlowControllerProvider.select((s) => s.screen));

    final body = switch (screen) {
      ClientScreen.splash => const SplashScreen(),
      ClientScreen.langSelect => const LangSelectScreen(),
      ClientScreen.onboarding => const OnboardingScreen(),
      ClientScreen.login => const LoginScreen(),
      ClientScreen.signup => const SignupScreen(),
      ClientScreen.otp => const OtpScreen(),
      ClientScreen.forgot => const ForgotScreen(),
      ClientScreen.locationPermission => const LocationPermissionScreen(),
      ClientScreen.notifPermission => const NotifPermissionScreen(),
      ClientScreen.home => const HomeScreen(),

      ClientScreen.rideOrigin => const RideOriginScreen(),
      ClientScreen.rideDestination => const RideDestinationScreen(),
      ClientScreen.rideConfirm => const RideConfirmScreen(),
      ClientScreen.searching => const SearchingScreen(),
      ClientScreen.noProvider => const NoProviderScreen(),
      ClientScreen.providerFound => const ProviderFoundScreen(),
      ClientScreen.tracking => const TrackingScreen(),
      ClientScreen.tripEnd => const TripEndScreen(),
      ClientScreen.tripRating => const TripRatingScreen(),

      ClientScreen.foodList => const FoodListScreen(),
      ClientScreen.restaurantDetail => const RestaurantDetailScreen(),
      ClientScreen.dishDetail => const DishDetailScreen(),
      ClientScreen.cart => const CartScreen(),
      ClientScreen.foodCheckout => const FoodCheckoutScreen(),
      ClientScreen.foodDeliveryAddress => const FoodDeliveryAddressScreen(),
      ClientScreen.foodWaiting => const FoodWaitingScreen(),
      ClientScreen.foodRejected => const FoodRejectedScreen(),
      ClientScreen.foodTracking => const FoodTrackingScreen(),
      ClientScreen.foodRating => const FoodRatingScreen(),

      ClientScreen.parcelPickup => const ParcelPickupScreen(),
      ClientScreen.parcelDropoff => const ParcelDropoffScreen(),
      ClientScreen.parcelDetails => const ParcelDetailsScreen(),
      ClientScreen.parcelConfirm => const ParcelConfirmScreen(),

      ClientScreen.voiceRecord => const VoiceRecordScreen(),
      ClientScreen.voiceAnalyzing => const VoiceAnalyzingScreen(),
      ClientScreen.voiceConfirm => const VoiceConfirmScreen(),
      ClientScreen.voiceFail => const VoiceFailScreen(),

      ClientScreen.orderHistory => const OrderHistoryScreen(),
      ClientScreen.profile => const ProfileScreen(),
      ClientScreen.settings => const SettingsScreen(),
      ClientScreen.notificationsList => const NotificationsListScreen(),
      ClientScreen.support => const SupportScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
    );
  }
}
