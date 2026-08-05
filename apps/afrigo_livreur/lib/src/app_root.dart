import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/delivery_end_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/navigate_to_dropoff_screen.dart';
import 'screens/navigate_to_pickup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rate_customer_screen.dart';
import 'screens/rejected_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vehicle_docs_screen.dart';
import 'screens/wallet_screen.dart';
import 'state/livreur_flow_controller.dart';
import 'state/livreur_screen.dart';

/// Renders whichever screen `LivreurFlowController.state.screen` points at.
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
    final screen = ref.watch(livreurFlowControllerProvider.select((s) => s.screen));

    final body = switch (screen) {
      LivreurScreen.splash => const SplashScreen(),
      LivreurScreen.login => const LoginScreen(),
      LivreurScreen.signup => const SignupScreen(),
      LivreurScreen.otp => const OtpScreen(),
      LivreurScreen.vehicleDocs => const VehicleDocsScreen(),
      LivreurScreen.pendingApproval => const PendingApprovalScreen(),
      LivreurScreen.rejected => const RejectedScreen(),
      LivreurScreen.home => const HomeScreen(),
      LivreurScreen.wallet => const WalletScreen(),
      LivreurScreen.navigateToPickup => const NavigateToPickupScreen(),
      LivreurScreen.navigateToDropoff => const NavigateToDropoffScreen(),
      LivreurScreen.deliveryEnd => const DeliveryEndScreen(),
      LivreurScreen.rateCustomer => const RateCustomerScreen(),
      LivreurScreen.history => const HistoryScreen(),
      LivreurScreen.profile => const ProfileScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
    );
  }
}
