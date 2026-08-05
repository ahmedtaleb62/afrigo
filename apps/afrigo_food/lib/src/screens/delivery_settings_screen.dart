import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

/// Delivery settings screen (linked from screens 67 & 72).
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

  @override
  void initState() {
    super.initState();
    final s = ref.read(foodFlowControllerProvider);
    _fee = TextEditingController(text: s.deliveryFee);
    _minOrder = TextEditingController(text: s.minOrder);
    _prepTime = TextEditingController(text: s.prepTime);
  }

  @override
  void dispose() {
    _fee.dispose();
    _minOrder.dispose();
    _prepTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    Widget option({required String emoji, required String title, required String subtitle, required DeliveryMethod value}) {
      final selected = s.deliveryMethod == value;
      return InkWell(
        onTap: () => controller.setDeliveryMethod(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: 2), color: selected ? const Color(0xFFF0FDF4) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$emoji $title', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                ],
              ),
              Text(selected ? '✅' : '', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

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
          const Text('طريقة التوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          option(emoji: '🛵', title: 'عبر مندوبي Afrigo', subtitle: 'نتكفّل نحن بالتوصيل لزبائنك', value: DeliveryMethod.afrigo),
          option(emoji: '🏍️', title: 'توصيل خاص بالمطعم', subtitle: 'لديك عمّال توصيل خاصون بك', value: DeliveryMethod.own),
          option(emoji: '🏪', title: 'استلام من المطعم فقط', subtitle: 'بدون خدمة توصيل', value: DeliveryMethod.pickup),
          if (s.deliveryMethod != DeliveryMethod.pickup) ...[
            FoodTextField(controller: _fee, label: 'رسوم التوصيل (أوقية)', keyboardType: TextInputType.number, onChanged: controller.setDeliveryFee),
            const SizedBox(height: 14),
          ],
          FoodTextField(controller: _minOrder, label: 'الحد الأدنى للطلب (أوقية)', keyboardType: TextInputType.number, onChanged: controller.setMinOrder),
          const SizedBox(height: 14),
          FoodTextField(controller: _prepTime, label: 'وقت التحضير التقديري', onChanged: controller.setPrepTime),
          const SizedBox(height: 20),
          FoodPrimaryButton(label: 'حفظ', onPressed: controller.saveDeliverySettings),
        ],
      ),
    );
  }
}
