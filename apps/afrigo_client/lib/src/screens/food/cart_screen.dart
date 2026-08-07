import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../core/context_ext.dart';

/// Screen 25 — Cart.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 16),
            child: Row(
              children: [
                BackCircleButton(onTap: controller.back),
                const SizedBox(width: 12),
                const Text('سلتك', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (var i = 0; i < s.cart.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F4)))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.cart[i].name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${s.cart[i].price} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                            ],
                          ),
                        ),
                        InkWell(onTap: () => controller.decCartQty(i), customBorder: const CircleBorder(), child: Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('−', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13)))),
                        SizedBox(width: 30, child: Text('${s.cart[i].qty}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13))),
                        InkWell(onTap: () => controller.incCartQty(i), customBorder: const CircleBorder(), child: Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)))),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                ClientTextField(hint: 'ملاحظة للمطعم (اختياري)', onChanged: controller.setOrderNote),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFAFAF9), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع الفرعي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))), Text('${s.cartSubtotal} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('رسوم التوصيل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))), Text('${s.cartDeliveryFee} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)), Text('${s.cartGrandTotal} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF166534)))]),
                    ],
                  ),
                ),
                if (!s.cartMeetsMinOrder && s.selectedRestaurantMinOrder != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'الحد الأدنى للطلب من هذا المطعم ${s.selectedRestaurantMinOrder!.toStringAsFixed(0)} أوقية',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ClientPrimaryButton(
              label: 'متابعة الطلب',
              onPressed: s.cartMeetsMinOrder ? () => controller.goTo(ClientScreen.foodCheckout) : null,
            ),
          ),
        ],
      ),
    );
  }
}
