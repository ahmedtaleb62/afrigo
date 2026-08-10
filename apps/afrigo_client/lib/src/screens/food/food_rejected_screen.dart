import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/client_primary_button.dart';
import '../../core/context_ext.dart';

/// Screen 28 — Restaurant rejected the order.
class FoodRejectedScreen extends ConsumerWidget {
  const FoodRejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final reason = ref.watch(clientFlowControllerProvider.select((s) => s.foodOrderFailureReason));
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(l10n.clientFoodOrderIncompleteTitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            reason ?? l10n.clientFoodOrderRejectedDefaultReason,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C)),
          ),
          const SizedBox(height: 24),
          ClientPrimaryButton(
            label: l10n.clientFoodChooseAnotherRestaurantButton,
            // Without clearing `hist`, this pushes the dead-end rejected
            // screen onto the stack — food list's own back button then
            // pops straight back into it, trapping the client in a
            // rejected↔foodList loop with no way to actually leave.
            onPressed: () => controller.goTo(ClientScreen.foodList, patch: (s) => s.copyWith(hist: const [])),
          ),
        ],
      ),
    );
  }
}
