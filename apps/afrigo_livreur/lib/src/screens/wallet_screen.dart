import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/livreur_flow_controller.dart';
import '../state/livreur_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/livreur_bottom_nav.dart';
import '../core/env.dart';

/// Screen — Wallet.
///
/// Balance is real (`watchWallet`, subscribed on login/home). The
/// transaction list stays as demo data.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openWhatsapp(String reason) {
    final text = Uri.encodeComponent('مرحبًا، أريد $reason رصيد محفظتي في تطبيق Afrigo Livreur.');
    launchUrl(Uri.parse('https://wa.me/${Env.supportPhone.replaceAll('+', '')}?text=$text'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final balance = ref.watch(livreurFlowControllerProvider.select((s) => s.resolvedBalance));

    Widget walletAction(String emoji, String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1C1917))),
                ],
              ),
            ),
          ),
        );

    Widget txn(String title, String time, String amount, {required bool positive}) => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
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
              Text(amount, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: positive ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
            ],
          ),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 54, 18, 6),
          child: Row(
            children: [
              BackCircleButton(onTap: () => controller.goTo(LivreurScreen.home)),
              const SizedBox(width: 12),
              const Text('المحفظة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1C1917))),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534))),
                    Text('${balance.toStringAsFixed(0)} أ.م', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 26, color: Color(0xFF166534))),
                    const SizedBox(height: 4),
                    const Text('نسبة العمولة: 15%', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF57534E))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  walletAction('💰', 'شحن رصيد', () => _openWhatsapp('شحن')),
                  const SizedBox(width: 10),
                  walletAction('🏧', 'سحب رصيد', () => _openWhatsapp('سحب')),
                ],
              ),
              const SizedBox(height: 20),
              const Text('سجل الحركات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
              const SizedBox(height: 10),
              txn('عمولة توصيل #781', 'اليوم 12:40', '-33 أ.م', positive: false),
              txn('شحن رصيد', 'أمس', '+500 أ.م', positive: true),
            ],
          ),
        ),
        LivreurBottomNav(current: LivreurScreen.wallet),
      ],
    );
  }
}
