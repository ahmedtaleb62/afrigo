import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/client_primary_button.dart';
import '../../core/context_ext.dart';

/// Screen 19 — Trip end summary.
class TripEndScreen extends ConsumerWidget {
  const TripEndScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    Widget row(String label, String value, {bool big = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
              Text(value, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: big ? 15 : 13, color: big ? const Color(0xFF166534) : const Color(0xFF1C1917))),
            ],
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        children: [
          Column(
            children: const [
              Text('✅', style: TextStyle(fontSize: 48)),
              SizedBox(height: 10),
              Text('تم الوصول بنجاح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 19)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFFAFAF9), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                row('المسافة', '${(s.orderDistanceKm ?? 0).toStringAsFixed(1)} كم'),
                if (s.orderDurationMin != null) row('المدة', '${s.orderDurationMin!.toStringAsFixed(0)} دقيقة'),
                row('السعر الإجمالي', '${(s.orderPrice ?? 0).toStringAsFixed(0)} أوقية', big: true),
              ],
            ),
          ),
          const Spacer(),
          ClientPrimaryButton(label: 'الدفع نقدًا - تم', onPressed: controller.payCashDone),
        ],
      ),
    );
  }
}
