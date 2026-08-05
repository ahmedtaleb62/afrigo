import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../state/livreur_screen.dart';

/// The 4-item bottom nav (الرئيسية/المحفظة/التوصيلات/الحساب) shown on Home,
/// Wallet, History and Profile.
class LivreurBottomNav extends ConsumerWidget {
  const LivreurBottomNav({super.key, required this.current});

  final LivreurScreen current;

  static const _screens = [LivreurScreen.home, LivreurScreen.wallet, LivreurScreen.history, LivreurScreen.profile];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final index = _screens.indexOf(current).clamp(0, _screens.length - 1);
    return AfrigoBottomNav(
      currentIndex: index,
      items: const [
        AfrigoNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
        AfrigoNavItem(icon: Icons.account_balance_wallet_rounded, label: 'المحفظة'),
        AfrigoNavItem(icon: Icons.receipt_long_rounded, label: 'التوصيلات'),
        AfrigoNavItem(icon: Icons.person_rounded, label: 'الحساب'),
      ],
      onTap: (i) => controller.goTo(_screens[i]),
    );
  }
}
