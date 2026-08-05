import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/account_creating_screen.dart';
import 'screens/home_screen.dart';
import 'screens/legal_text_screen.dart';
import 'screens/login_screen.dart';
import 'screens/navigate_to_pickup_screen.dart';
import 'screens/notifications_list_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rate_customer_screen.dart';
import 'screens/rejected_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/support_screen.dart';
import 'screens/trip_end_summary_screen.dart';
import 'screens/trip_history_screen.dart';
import 'screens/trip_ongoing_screen.dart';
import 'screens/vehicle_docs_screen.dart';
import 'screens/wallet_screen.dart';
import 'state/taxi_flow_controller.dart';
import 'state/taxi_screen.dart';

/// Renders whichever screen `TaxiFlowController.state.screen` points at.
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
    final screen = ref.watch(taxiFlowControllerProvider.select((s) => s.screen));

    // Was previously only listened to inside HomeScreen, so a failed
    // transition made while on e.g. TripOngoingScreen (exactly where
    // startTripOngoing/endTripDriver run) never surfaced to the driver at
    // all — the app just silently stayed out of sync with the server.
    ref.listen(taxiFlowControllerProvider.select((s) => s.actionError), (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      ref.read(taxiFlowControllerProvider.notifier).clearActionError();
    });

    final body = switch (screen) {
      TaxiScreen.splash => const SplashScreen(),
      TaxiScreen.login => const LoginScreen(),
      TaxiScreen.signup => const SignupScreen(),
      TaxiScreen.otp => const OtpScreen(),
      TaxiScreen.accountCreating => const AccountCreatingScreen(),
      TaxiScreen.vehicleDocs => const VehicleDocsScreen(),
      TaxiScreen.pendingApproval => const PendingApprovalScreen(),
      TaxiScreen.rejected => const RejectedScreen(),
      TaxiScreen.home => const HomeScreen(),
      TaxiScreen.wallet => const WalletScreen(),
      TaxiScreen.navigateToPickup => const NavigateToPickupScreen(),
      TaxiScreen.tripOngoing => const TripOngoingScreen(),
      TaxiScreen.tripEndSummary => const TripEndSummaryScreen(),
      TaxiScreen.rateCustomer => const RateCustomerScreen(),
      TaxiScreen.tripHistory => const TripHistoryScreen(),
      TaxiScreen.profile => const ProfileScreen(),
      TaxiScreen.notificationsList => const NotificationsListScreen(),
      TaxiScreen.support => const SupportScreen(),
      TaxiScreen.about => LegalTextScreen(
          title: 'عن التطبيق',
          body: ref.watch(taxiFlowControllerProvider.select((s) => s.aboutText)),
          onBack: () => ref.read(taxiFlowControllerProvider.notifier).back(),
        ),
      TaxiScreen.terms => LegalTextScreen(
          title: 'الشروط والأحكام',
          body: ref.watch(taxiFlowControllerProvider.select((s) => s.termsText)),
          onBack: () => ref.read(taxiFlowControllerProvider.notifier).back(),
        ),
      TaxiScreen.privacy => LegalTextScreen(
          title: 'سياسة الخصوصية',
          body: ref.watch(taxiFlowControllerProvider.select((s) => s.privacyText)),
          onBack: () => ref.read(taxiFlowControllerProvider.notifier).back(),
        ),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
    );
  }
}
