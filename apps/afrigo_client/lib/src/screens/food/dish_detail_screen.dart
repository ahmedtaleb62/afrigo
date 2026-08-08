import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/back_circle_button.dart';
import '../../core/context_ext.dart';

/// Screen 24 — Dish detail. Real dish, set by `ClientFlowController.openDish`.
class DishDetailScreen extends ConsumerWidget {
  const DishDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final qty = ref.watch(clientFlowControllerProvider.select((s) => s.dishQty));
    final dish = ref.watch(clientFlowControllerProvider.select((s) => s.selectedDish));
    final name = dish?['name'] as String? ?? '';
    final description = dish?['description'] as String? ?? '';
    final price = (dish?['price'] as num?)?.toInt() ?? 0;
    final stock = (dish?['stock_quantity'] as num?)?.toInt();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Container(color: const Color(0xFFFEF9C3), alignment: Alignment.center, child: const Text('🍕', style: TextStyle(fontSize: 60))),
                Positioned(top: context.topGap(12), right: 16, child: BackCircleButton(onTap: controller.back, onLight: true)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 19)),
                  const SizedBox(height: 6),
                  if (description.isNotEmpty)
                    Text(description, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الكمية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.setDishQty(qty - 1),
                            customBorder: const CircleBorder(),
                            child: Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('−', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16))),
                          ),
                          SizedBox(width: 40, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15))),
                          InkWell(
                            onTap: () => controller.setDishQty(qty + 1),
                            customBorder: const CircleBorder(),
                            child: Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (stock != null && stock > 0 && stock <= 5) ...[
                    const SizedBox(height: 6),
                    Text('الكمية المتاحة: $stock فقط', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFFDC2626))),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: dish == null ? null : controller.addSelectedDishToCart,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('أضف إلى السلة · ${qty * price} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
