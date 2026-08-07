import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/livreur_primary_button.dart';

/// Screen 80 — Delivery end summary (with commission breakdown).
class DeliveryEndScreen extends ConsumerWidget {
  const DeliveryEndScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final s = ref.watch(livreurFlowControllerProvider);
    final delivery = s.activeDelivery;
    final commissionPct = s.commissionPct ?? 0;
    final price = delivery?.price ?? 0;
    final commission = price * commissionPct / 100;
    final net = price - commission;

    Widget row(String label, String value, {Color? valueColor, bool big = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: big ? 15 : 13, fontWeight: big ? FontWeight.w800 : FontWeight.w400, color: big ? const Color(0xFF1C1917) : const Color(0xFF57534E))),
              Text(value, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: big ? 15 : 13, color: valueColor ?? const Color(0xFF1C1917))),
            ],
          ),
        );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          const Column(children: [Text('📦', style: TextStyle(fontSize: 44)), SizedBox(height: 8), Text('تم تسليم الطرد بنجاح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18))]),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                if (delivery?.distanceKm != null) row('المسافة', '${delivery!.distanceKm!.toStringAsFixed(1)} كم'),
                row('سعر التوصيل', '${price.toStringAsFixed(0)} أ.م'),
                row('عمولة المنصة (${commissionPct.toStringAsFixed(0)}%)', '-${commission.toStringAsFixed(0)} أ.م', valueColor: const Color(0xFFDC2626)),
                Container(margin: const EdgeInsets.symmetric(vertical: 4), height: 1, color: const Color(0xFFE7E5E4)),
                row('صافي الربح', '${net.toStringAsFixed(0)} أ.م', big: true),
              ],
            ),
          ),
          const Spacer(),
          LivreurPrimaryButton(label: 'متابعة', onPressed: controller.goToRateCustomer),
        ],
      ),
    );
  }
}
