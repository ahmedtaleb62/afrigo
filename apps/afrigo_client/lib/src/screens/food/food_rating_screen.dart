import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/client_primary_button.dart';
import '../../core/context_ext.dart';

/// Screen 30 — Food order rating (restaurant + delivery).
class FoodRatingScreen extends ConsumerWidget {
  const FoodRatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    Widget stars(int value, ValueChanged<int> onRate) => Row(
          children: List.generate(5, (i) {
            final filled = value >= i + 1;
            return InkWell(
              onTap: () => onRate(i + 1),
              child: Padding(padding: const EdgeInsets.only(left: 6), child: Text(filled ? '⭐' : '☆', style: const TextStyle(fontSize: 26))),
            );
          }),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('قيّم تجربتك', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18))),
          const SizedBox(height: 20),
          const Text('تقييم المطعم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          stars(s.foodRatingRestaurant, controller.rateRestaurant),
          const SizedBox(height: 20),
          const Text('تقييم عامل التوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          stars(s.foodRatingDelivery, controller.rateDelivery),
          const Spacer(),
          ClientPrimaryButton(label: 'إرسال التقييم', onPressed: controller.finishFoodRating),
        ],
      ),
    );
  }
}
