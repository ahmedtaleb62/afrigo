import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_bottom_nav.dart';
import '../core/env.dart';

/// Screen 70 — Wallet & commission. Balance and transaction history are
/// both real (`watchWallet`/`loadWalletTransactions`).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openWhatsapp(String reason) {
    final text = Uri.encodeComponent('مرحبًا، أريد $reason رصيد محفظتي في تطبيق Afrigo Food.');
    launchUrl(Uri.parse('https://wa.me/${Env.supportPhone.replaceAll('+', '')}?text=$text'), mode: LaunchMode.externalApplication);
  }

  static String _formatTxnDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    final now = DateTime.now();
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'اليوم $time';
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) return 'أمس $time';
    return '${d.year}/${d.month}/${d.day}';
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
              if (s.walletTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('لا توجد حركات بعد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C)))),
                )
              else
                for (final t in s.walletTransactions)
                  txn(
                    (t['note'] as String?)?.trim().isNotEmpty == true ? t['note'] as String : (t['type'] == 'topup' ? 'شحن رصيد' : 'خصم عمولة'),
                    _formatTxnDate(t['created_at'] as String?),
                    '${t['type'] == 'topup' ? '+' : '-'}${((t['amount'] as num?) ?? 0).toStringAsFixed(0)} أوقية',
                    positive: t['type'] == 'topup',
                  ),
            ],
          ),
        ),
        const FoodBottomNav(current: FoodScreen.wallet),
      ],
    );
  }
}
