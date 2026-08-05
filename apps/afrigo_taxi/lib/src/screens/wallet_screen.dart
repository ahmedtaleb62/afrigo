import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/taxi_bottom_nav.dart';

/// Screen 53 — Wallet. Balance (`watchWallet`) and transaction list
/// (`loadWalletTransactions`, real `wallet_transactions` rows) are both
/// real now.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openWhatsapp(String supportPhone, String reason) {
    final text = Uri.encodeComponent('مرحبًا، أريد $reason رصيد محفظتي في تطبيق Afrigo Taxi.');
    launchUrl(Uri.parse('https://wa.me/${supportPhone.replaceAll('+', '')}?text=$text'), mode: LaunchMode.externalApplication);
  }

  static const _typeLabel = {'topup': 'شحن رصيد', 'commission_deduction': 'عمولة رحلة', 'admin_withdrawal': 'سحب رصيد'};

  String _formatTime(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return isToday ? 'اليوم $time' : '${d.year}/${d.month}/${d.day} $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final balance = ref.watch(taxiFlowControllerProvider.select((s) => s.resolvedBalance));
    final commissionPct = ref.watch(taxiFlowControllerProvider.select((s) => s.commissionPct));
    final txns = ref.watch(taxiFlowControllerProvider.select((s) => s.walletTransactions));
    final txnsLoading = ref.watch(taxiFlowControllerProvider.select((s) => s.walletTransactionsLoading));
    final supportPhone = ref.watch(taxiFlowControllerProvider.select((s) => s.supportPhone));

    Widget walletAction(String emoji, String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
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
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
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
              Text(amount, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: positive ? const Color(0xFF166534) : const Color(0xFFDC2626))),
            ],
          ),
        );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 14, 18, 6),
          child: Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('المحفظة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1C1917))),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: ListView(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF166534))),
                      Text('${balance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 26, color: Color(0xFF166534))),
                      const SizedBox(height: 4),
                      Text('نسبة العمولة: ${commissionPct?.toStringAsFixed(0) ?? '...'}%', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF57534E))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    walletAction('💰', 'شحن رصيد', () => _openWhatsapp(supportPhone, 'شحن')),
                    const SizedBox(width: 10),
                    walletAction('🏧', 'سحب رصيد', () => _openWhatsapp(supportPhone, 'سحب')),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('سجل الحركات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 10),
                if (txnsLoading && txns.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()))
                else if (txns.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('لا توجد حركات بعد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C)))))
                else
                  for (final t in txns)
                    txn(
                      (t['note'] as String?)?.trim().isNotEmpty == true ? t['note'] as String : (_typeLabel[t['type']] ?? 'حركة'),
                      _formatTime(t['created_at'] as String?),
                      '${(t['amount'] as num) > 0 ? '+' : ''}${(t['amount'] as num).toStringAsFixed(0)} أوقية',
                      positive: (t['amount'] as num) > 0,
                    ),
              ],
            ),
          ),
        ),
        const TaxiBottomNav(current: TaxiScreen.wallet),
      ],
    );
  }
}
