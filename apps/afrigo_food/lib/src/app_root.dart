import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/bike_docs_screen.dart';
import 'screens/delivery_settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rejected_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/restaurant_docs_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/wallet_screen.dart';
import 'state/food_flow_controller.dart';
import 'state/food_screen.dart';

/// Renders whichever screen `FoodFlowController.state.screen` points at.
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
    final screen = ref.watch(foodFlowControllerProvider.select((s) => s.screen));

    final body = switch (screen) {
      FoodScreen.splash => const SplashScreen(),
      FoodScreen.login => const LoginScreen(),
      FoodScreen.signup => const SignupScreen(),
      FoodScreen.otp => const OtpScreen(),
      FoodScreen.restaurantDocs => const RestaurantDocsScreen(),
      FoodScreen.bikeDocs => const BikeDocsScreen(),
      FoodScreen.pendingApproval => const PendingApprovalScreen(),
      FoodScreen.rejected => const RejectedScreen(),
      FoodScreen.home => const HomeScreen(),
      FoodScreen.menu => const MenuScreen(),
      FoodScreen.deliverySettings => const DeliverySettingsScreen(),
      FoodScreen.orders => const OrdersScreen(),
      FoodScreen.orderDetail => const OrderDetailScreen(),
      FoodScreen.wallet => const WalletScreen(),
      FoodScreen.reports => const ReportsScreen(),
      FoodScreen.profile => const ProfileScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
    );
  }
}
