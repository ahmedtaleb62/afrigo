import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

/// Delivery settings screen (linked from screens 67 & 72). Simplified to
/// just delivery fee + prep time per an explicit request — see the doc
/// comment on `FoodFlowController`'s delivery-settings section for why
/// the delivery-method selector and min-order field were dropped.
/// `saveDeliverySettings()` really persists to `restaurants`.
class DeliverySettingsScreen extends ConsumerStatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  ConsumerState<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends ConsumerState<DeliverySettingsScreen> {
  late final TextEditingController _fee;
  late final TextEditingController _prepTime;

  @override
  void initState() {
    super.initState();
    final s = ref.read(foodFlowControllerProvider);
    _fee = TextEditingController(text: s.deliveryFee);
    _prepTime = TextEditingController(text: s.prepTime);
    Future.microtask(() async {
      await ref.read(foodFlowControllerProvider.notifier).loadDeliverySettings();
      if (!mounted) return;
      final loaded = ref.read(foodFlowControllerProvider);
      _fee.text = loaded.deliveryFee;
      _prepTime.text = loaded.prepTime;
    });
  }

  @override
  void dispose() {
    _fee.dispose();
    _prepTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
      child: ListView(
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('إعدادات التوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          FoodTextField(controller: _fee, label: 'رسوم التوصيل (أوقية)', keyboardType: TextInputType.number, onChanged: controller.setDeliveryFee),
          const SizedBox(height: 14),
          FoodTextField(controller: _prepTime, label: 'وقت التحضير التقديري', onChanged: controller.setPrepTime),
          const SizedBox(height: 20),
          FoodPrimaryButton(label: 'حفظ', onPressed: controller.saveDeliverySettings),
        ],
      ),
    );
  }
}
