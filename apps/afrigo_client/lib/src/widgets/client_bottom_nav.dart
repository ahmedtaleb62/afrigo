import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';

/// The 3-item bottom nav (الرئيسية/طلباتي/الحساب) shown on Home, Order
/// History and Profile (screens 10, 40, 41).
class ClientBottomNav extends ConsumerWidget {
  const ClientBottomNav({super.key, required this.current});

  final ClientScreen current;

  static const _screens = [ClientScreen.home, ClientScreen.orderHistory, ClientScreen.profile];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final index = _screens.indexOf(current).clamp(0, _screens.length - 1);
    return AfrigoBottomNav(
      currentIndex: index,
      items: const [
        AfrigoNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
        AfrigoNavItem(icon: Icons.receipt_long_rounded, label: 'طلباتي'),
        AfrigoNavItem(icon: Icons.person_rounded, label: 'الحساب'),
      ],
      onTap: (i) => controller.goTo(_screens[i]),
    );
  }
}
