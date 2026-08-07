import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/livreur_primary_button.dart';

/// Screen — Rate customer.
class RateCustomerScreen extends ConsumerWidget {
  const RateCustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final rating = ref.watch(livreurFlowControllerProvider.select((s) => s.custRating));
    final recipientName = ref.watch(livreurFlowControllerProvider.select((s) => s.activeDelivery?.recipientName));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('👩', style: TextStyle(fontSize: 26))),
          const SizedBox(height: 14),
          Text('قيّم الزبون${recipientName != null ? ': $recipientName' : ''}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = rating >= i + 1;
              return InkWell(
                onTap: () => controller.rateCustomer(i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(filled ? '⭐' : '☆', style: const TextStyle(fontSize: 30))),
              );
            }),
          ),
          const Spacer(),
          LivreurPrimaryButton(label: 'إرسال', onPressed: controller.finishRating),
        ],
      ),
    );
  }
}
