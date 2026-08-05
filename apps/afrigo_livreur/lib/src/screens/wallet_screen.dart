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
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
        );

    Widget txn(String title, String time, String amount, {required bool positive}) => Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(time, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))),
                ],
              ),
              Text(amount, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: positive ? const Color(0xFF176F3D) : const Color(0xFFDC2626))),
            ],
          ),
        );

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF0F3F23),
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackCircleButton(onTap: () => controller.goTo(LivreurScreen.home), onDark: true),
                  const SizedBox(width: 12),
                  const Text('المحفظة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFFB3E7C4))),
              Text('${balance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 28, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('نسبة العمولة: 15%', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFFB3E7C4))),
              const SizedBox(height: 16),
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
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9F8),
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text('سجل الحركات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C8574))),
                const SizedBox(height: 10),
                txn('عمولة توصيل #781', 'اليوم 12:40', '-33 أوقية', positive: false),
                txn('شحن رصيد', 'أمس', '+500 أوقية', positive: true),
              ],
            ),
          ),
        ),
        const LivreurBottomNav(current: LivreurScreen.wallet),
      ],
    );
  }
}
