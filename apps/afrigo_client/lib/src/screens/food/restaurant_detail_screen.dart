import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../core/context_ext.dart';

/// Screen 23 — Restaurant detail (menu). Real `restaurant_dishes` rows,
/// loaded by `ClientFlowController.openRestaurant`.
class RestaurantDetailScreen extends ConsumerWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final cartHasItems = s.cart.isNotEmpty;
    final cartCount = s.cartCount;
    final cartTotal = s.cart.fold(0, (a, i) => a + i.qty * i.price);
    final l10n = context.l10n;

    Widget dishRow(Map<String, dynamic> dish) {
      final name = dish['name'] as String? ?? '';
      final desc = dish['description'] as String? ?? '';
      final price = (dish['price'] as num?)?.toInt() ?? 0;
      return InkWell(
        onTap: s.selectedRestaurantIsOpen ? () => controller.openDish(dish) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F4)))),
          child: Row(
            children: [
              Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(12)), child: const Text('🍽️', style: TextStyle(fontSize: 22))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
                    if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                    Text(l10n.clientFoodAmountMru(price), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF166534))),
                  ],
                ),
              ),
              Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: s.selectedRestaurantIsOpen ? const Color(0xFF16A34A) : const Color(0xFFD6D3D1), shape: BoxShape.circle), child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 16))),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ListView(
            children: [
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFACC15), Color(0xFFFDE047)])),
                child: Stack(
                  children: [
                    const Center(child: Text('🍕', style: TextStyle(fontSize: 40))),
                    Positioned(top: context.topGap(12), right: 16, child: BackCircleButton(onTap: controller.back, onLight: true)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.selectedRestaurantName ?? '', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 19)),
                    if (!s.selectedRestaurantIsOpen) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(10)),
                        child: Text(l10n.clientFoodRestaurantClosedMessage, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (s.restaurantDishes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(l10n.clientFoodNoDishesAvailable, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C)))),
                      )
                    else
                      for (final dish in s.restaurantDishes) dishRow(dish),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          if (cartHasItems)
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: InkWell(
                onTap: () => controller.goTo(ClientScreen.cart),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6))]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.clientFoodViewCartButton(cartCount), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                      Text(l10n.clientFoodAmountMru(cartTotal), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
