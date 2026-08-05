import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/spinning_ring.dart';

/// Screen 47 — Account creating.
class AccountCreatingScreen extends ConsumerWidget {
  const AccountCreatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinningRing(),
          const SizedBox(height: 16),
          const Text('جارٍ إنشاء حسابك...', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('سننتقل الآن لتوثيق مركبتك', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => controller.goTo(TaxiScreen.vehicleDocs),
            style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
            child: const Text('متابعة إلى التوثيق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
