import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_bottom_nav.dart';
import '../core/env.dart';

/// Screen 70 — Wallet & commission.
///
/// Balance is real (`watchWallet`). Transaction list stays demo data — see
/// `apps/afrigo_food/README.md`.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openWhatsapp(String reason) {
    final text = Uri.encodeComponent('مرحبًا، أريد $reason رصيد محفظتي في تطبيق Afrigo Food.');
    launchUrl(Uri.parse('https://wa.me/${Env.supportPhone.replaceAll('+', '')}?text=$text'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);
    final balance = s.resolvedBalance;

    Widget walletAction(String emoji, String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
                ],
              ),
            ),
          ),
        );

    Widget txn(String title, String time, String amount, {required bool positive}) => Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(time, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                ],
              ),
              Text(amount, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 13, color: positive ? const Color(0xFF166534) : const Color(0xFFDC2626))),
            ],
          ),
        );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 6),
          child: Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('المحفظة والعمولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1C1917))),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF166534))),
                    Text('${balance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 26, color: Color(0xFF166534))),
                    Text('نسبة العمولة: ${s.commissionPct?.toStringAsFixed(0) ?? '...'}%', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF57534E))),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        walletAction('💰', 'شحن رصيد', () => _openWhatsapp('شحن')),
                        const SizedBox(width: 10),
                        walletAction('🏧', 'سحب رصيد', () => _openWhatsapp('سحب')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('سجل الحركات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
              const SizedBox(height: 10),
              txn('عمولة طلب #2051', 'اليوم 13:10', '-148 أوقية', positive: false),
              txn('شحن رصيد', 'أمس', '+2,000 أوقية', positive: true),
            ],
          ),
        ),
        const FoodBottomNav(current: FoodScreen.wallet),
      ],
    );
  }
}
