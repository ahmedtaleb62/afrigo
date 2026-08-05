import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/client_primary_button.dart';

/// Screen 28 — Restaurant rejected the order.
class FoodRejectedScreen extends ConsumerWidget {
  const FoodRejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('اعتذر المطعم عن قبول طلبك', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('قد يكون المطعم مشغولًا حاليًا. لن يتم خصم أي مبلغ منك', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
          const SizedBox(height: 24),
          ClientPrimaryButton(label: 'اختيار مطعم آخر', onPressed: () => controller.goTo(ClientScreen.foodList)),
        ],
      ),
    );
  }
}
