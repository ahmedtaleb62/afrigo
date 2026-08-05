import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';

/// The 3-item bottom nav (الرئيسية/المحفظة/الحساب) shown on Home, Wallet
/// and Profile.
class FoodBottomNav extends ConsumerWidget {
  const FoodBottomNav({super.key, required this.current});

  final FoodScreen current;

  static const _screens = [FoodScreen.home, FoodScreen.wallet, FoodScreen.profile];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final index = _screens.indexOf(current).clamp(0, _screens.length - 1);
    return AfrigoBottomNav(
      currentIndex: index,
      items: const [
        AfrigoNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
        AfrigoNavItem(icon: Icons.account_balance_wallet_rounded, label: 'المحفظة'),
        AfrigoNavItem(icon: Icons.person_rounded, label: 'الحساب'),
      ],
      onTap: (i) => controller.goTo(_screens[i]),
    );
  }
}
