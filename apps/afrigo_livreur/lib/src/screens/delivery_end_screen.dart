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
    final commission = (delivery?.price ?? 0) * commissionPct / 100;

    Widget row(String label, String value, {bool big = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: big ? 14 : 13, fontWeight: big ? FontWeight.w800 : FontWeight.w400, color: big ? const Color(0xFF1A1D16) : const Color(0xFF7C8574))),
              Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1D16))),
            ],
          ),
        );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          const Column(children: [Text('✅', style: TextStyle(fontSize: 44)), SizedBox(height: 8), Text('تم تسليم الطرد بنجاح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18))]),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFF8F9F8), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                if (delivery?.distanceKm != null) row('المسافة', '${delivery!.distanceKm!.toStringAsFixed(1)} كم'),
                row('السعر', '${(delivery?.price ?? 0).toStringAsFixed(0)} أوقية'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('العمولة المخصومة (${commissionPct.toStringAsFixed(0)}%)', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('-${commission.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFDC2626))),
                  ],
                ),
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
