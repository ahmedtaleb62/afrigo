import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';

/// Screen 75 — Pending approval.
///
/// Watches the driver's `vehicles` row live via Realtime
/// (`watchVehicleStatus`, started right after `submitVehicleDocs`) and
/// auto-navigates to Home/Rejected the moment an admin actually reviews it.
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 52)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(999)),
            child: const Text('قيد المراجعة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF8F660C))),
          ),
          const Text('بانتظار موافقة الإدارة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('سيتم إشعارك فور المراجعة. لا يمكنك استقبال الطلبات في هذه الأثناء', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF7C8574))),
          const SizedBox(height: 24),
          TextButton(
            onPressed: controller.simulateRejected,
            child: const Text('معاينة: حالة الرفض ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFFA3AB9C))),
          ),
        ],
      ),
    );
  }
}
