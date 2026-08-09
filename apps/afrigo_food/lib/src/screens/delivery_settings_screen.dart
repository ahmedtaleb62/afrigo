import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

/// سياسة المطعم — Restaurant Policies screen (linked from screens 67 & 72).
/// Consolidates delivery fee, prep time, min order, and a client-facing
/// contact/support number in one place per an explicit request.
/// `saveDeliverySettings()` really persists to `restaurants`.
class DeliverySettingsScreen extends ConsumerStatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  ConsumerState<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends ConsumerState<DeliverySettingsScreen> {
  late final TextEditingController _fee;
  late final TextEditingController _minOrder;
  late final TextEditingController _prepTime;
  late final TextEditingController _contactPhone;

  @override
  void initState() {
    super.initState();
    final s = ref.read(foodFlowControllerProvider);
    _fee = TextEditingController(text: s.deliveryFee);
    _minOrder = TextEditingController(text: s.minOrder);
    _prepTime = TextEditingController(text: s.prepTime);
    _contactPhone = TextEditingController(text: s.contactPhone);
    Future.microtask(() async {
      await ref.read(foodFlowControllerProvider.notifier).loadDeliverySettings();
      if (!mounted) return;
      final loaded = ref.read(foodFlowControllerProvider);
      _fee.text = loaded.deliveryFee;
      _minOrder.text = loaded.minOrder;
      _prepTime.text = loaded.prepTime;
      _contactPhone.text = loaded.contactPhone;
    });
  }

  @override
  void dispose() {
    _fee.dispose();
    _minOrder.dispose();
    _prepTime.dispose();
    _contactPhone.dispose();
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
              const Text('سياسة المطعم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          FoodTextField(controller: _fee, label: 'رسوم التوصيل (أوقية)', keyboardType: TextInputType.number, onChanged: controller.setDeliveryFee),
          const SizedBox(height: 14),
          FoodTextField(controller: _minOrder, label: 'الحد الأدنى للطلب (أوقية)', keyboardType: TextInputType.number, onChanged: controller.setMinOrder),
          const SizedBox(height: 14),
          FoodTextField(controller: _prepTime, label: 'وقت التحضير التقديري', onChanged: controller.setPrepTime),
          const SizedBox(height: 14),
          FoodTextField(controller: _contactPhone, label: 'رقم الدعم (يظهر للعميل)', keyboardType: TextInputType.phone, onChanged: controller.setContactPhone),
          const SizedBox(height: 20),
          FoodPrimaryButton(label: 'حفظ', onPressed: controller.saveDeliverySettings),
        ],
      ),
    );
  }
}
