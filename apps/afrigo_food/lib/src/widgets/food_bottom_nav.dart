import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';

/// The 4-item bottom nav (الرئيسية/الطلبات/المحفظة/الحساب) shown on Home,
/// Orders, Wallet and Profile.
class FoodBottomNav extends ConsumerWidget {
  const FoodBottomNav({super.key, required this.current});

  final FoodScreen current;

  static const _screens = [FoodScreen.home, FoodScreen.orders, FoodScreen.wallet, FoodScreen.profile];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final index = _screens.indexOf(current).clamp(0, _screens.length - 1);
    return AfrigoBottomNav(
      currentIndex: index,
      items: const [
        AfrigoNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
        AfrigoNavItem(icon: Icons.receipt_long_rounded, label: 'الطلبات'),
        AfrigoNavItem(icon: Icons.account_balance_wallet_rounded, label: 'المحفظة'),
        AfrigoNavItem(icon: Icons.person_rounded, label: 'الحساب'),
      ],
      onTap: (i) => _screens[i] == current ? null : controller.goTo(_screens[i]),
    );
  }
}
