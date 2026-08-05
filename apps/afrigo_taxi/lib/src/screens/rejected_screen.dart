import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/taxi_primary_button.dart';

/// Screen 50 — Verification rejected.
class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final reason = ref.watch(taxiFlowControllerProvider.select((s) => s.vehicleRejectionReason));
    final display = reason?.isNotEmpty == true ? reason! : 'صورة رخصة القيادة غير واضحة، الرجاء رفع صورة أوضح';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(999)),
            child: const Text('مرفوض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFDC2626))),
          ),
          const Text('تم رفض طلب التوثيق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: Text('سبب الرفض: $display', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
          ),
          TaxiPrimaryButton(label: 'إعادة تقديم الطلب', onPressed: () => controller.goTo(TaxiScreen.vehicleDocs)),
        ],
      ),
    );
  }
}
