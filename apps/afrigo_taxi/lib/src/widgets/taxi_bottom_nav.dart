import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';

/// The 4-item bottom nav (الرئيسية/المحفظة/الرحلات/الحساب) shown on Home,
/// Wallet, Trip History and Profile (screens 51, 53, 59, 60).
class TaxiBottomNav extends ConsumerWidget {
  const TaxiBottomNav({super.key, required this.current});

  final TaxiScreen current;

  static const _screens = [TaxiScreen.home, TaxiScreen.tripHistory, TaxiScreen.wallet, TaxiScreen.profile];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final index = _screens.indexOf(current).clamp(0, _screens.length - 1);
    return AfrigoBottomNav(
      currentIndex: index,
      items: const [
        AfrigoNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
        AfrigoNavItem(icon: Icons.receipt_long_rounded, label: 'الرحلات'),
        AfrigoNavItem(icon: Icons.account_balance_wallet_rounded, label: 'المحفظة'),
        AfrigoNavItem(icon: Icons.person_rounded, label: 'الحساب'),
      ],
      onTap: (i) => _screens[i] == current ? null : controller.goTo(_screens[i]),
    );
  }
}
