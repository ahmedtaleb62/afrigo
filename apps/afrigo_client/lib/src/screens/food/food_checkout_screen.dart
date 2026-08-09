import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../widgets/payment_method_field.dart';
import '../../core/context_ext.dart';

/// Screen 26 — Food checkout.
class FoodCheckoutScreen extends ConsumerWidget {
  const FoodCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final grandTotal = ref.watch(clientFlowControllerProvider.select((s) => s.cartGrandTotal));
    final meetsMinOrder = ref.watch(clientFlowControllerProvider.select((s) => s.cartMeetsMinOrder));
    final paymentMethod = ref.watch(clientFlowControllerProvider.select((s) => s.paymentMethod));
    final dropoffAddress = ref.watch(clientFlowControllerProvider.select((s) => s.dropoffAddress));
    final isPickup = ref.watch(clientFlowControllerProvider.select((s) => s.foodIsPickup));
    final minOrder = ref.watch(clientFlowControllerProvider.select((s) => s.selectedRestaurantMinOrder));

    Widget pickupOption(String label, String emoji, bool value) {
      final selected = isPickup == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.setFoodIsPickup(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: selected ? 2 : 1.5),
              color: selected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: selected ? const Color(0xFF166534) : const Color(0xFF1C1917))),
              ],
            ),
          ),
        ),
      );
    }

    Widget row(String label, String trailing, {VoidCallback? onTap}) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13))),
                Text(trailing, style: TextStyle(fontFamily: 'Tajawal', fontWeight: onTap == null ? FontWeight.w700 : FontWeight.normal, fontSize: 12, color: onTap == null ? const Color(0xFF166534) : const Color(0xFFA8A29E))),
              ],
            ),
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('تأكيد الطلب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('طريقة الاستلام', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          Row(children: [pickupOption('توصيل', '🛵', false), const SizedBox(width: 10), pickupOption('استلام من المطعم', '🏪', true)]),
          const SizedBox(height: 16),
          if (!isPickup) ...[
            const Text('عنوان التسليم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
            const SizedBox(height: 8),
            row(dropoffAddress ?? 'اختر عنوان التوصيل', 'تعديل', onTap: () => controller.goTo(ClientScreen.foodDeliveryAddress)),
          ],
          const Text('طريقة الدفع', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          PaymentMethodField(value: paymentMethod, onChanged: controller.setPaymentMethod),
          ClientTextField(hint: 'ملاحظة للمطعم (اختياري)', onChanged: controller.setOrderNote),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFAFAF9), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي النهائي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                Text('$grandTotal أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF166534))),
              ],
            ),
          ),
          if (!meetsMinOrder && minOrder != null && minOrder > 0) ...[
            const SizedBox(height: 10),
            Text(
              'الحد الأدنى للطلب في هذا المطعم ${minOrder.toStringAsFixed(0)} أوقية',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFFDC2626)),
            ),
          ],
          const Spacer(),
          ClientPrimaryButton(label: 'أرسل الطلب', onPressed: meetsMinOrder ? controller.placeFoodOrder : null),
        ],
      ),
    );
  }
}
