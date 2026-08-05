import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/dish.dart';
import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_text_field.dart';

/// Screen 67 — Menu management.
///
/// Fully real: loads `restaurant_dish_categories`/`restaurant_dishes` for
/// the signed-in owner's restaurant on open, and every toggle/stock/add
/// action here writes straight back to Supabase.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _newDishName = TextEditingController();
  final _newDishPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodFlowControllerProvider.notifier).loadMenu());
  }

  @override
  void dispose() {
    _newDishName.dispose();
    _newDishPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    return Container(
      color: const Color(0xFFF8F9F8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 12),
            child: Row(
              children: [
                BackCircleButton(onTap: controller.back),
                const SizedBox(width: 12),
                const Expanded(child: Text('إدارة القائمة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17))),
                InkWell(
                  onTap: controller.toggleAddDish,
                  customBorder: const CircleBorder(),
                  child: Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF2AA35C), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white))),
                ),
              ],
            ),
          ),
          if (s.addDishOpen)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Column(
                children: [
                  FoodTextField(controller: _newDishName, hint: 'اسم الطبق الجديد', small: true),
                  const SizedBox(height: 8),
                  FoodTextField(controller: _newDishPrice, hint: 'السعر (أوقية)', small: true, keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.addDish(_newDishName.text, num.tryParse(_newDishPrice.text) ?? 0),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2AA35C), foregroundColor: Colors.white, padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('حفظ الطبق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            color: const Color(0xFFEFFBF3),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFB3E7C4)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🚚 التوصيل: ${s.deliveryMethodLabel}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF176F3D))),
                InkWell(
                  onTap: () => controller.goTo(FoodScreen.deliverySettings),
                  child: const Text('تعديل ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF176F3D))),
                ),
              ],
            ),
          ),
          Expanded(
            child: s.menuLoading
                ? const Center(child: CircularProgressIndicator())
                : s.categories.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('لا توجد أطباق بعد — اضغط + لإضافة أول طبق', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF7C8574))),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (final category in s.categories) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(category.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF176F3D))),
                                if (category == s.categories.first)
                                  InkWell(
                                    onTap: controller.addCategoryDemo,
                                    child: const Text('+ تصنيف جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF7C8574))),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (final dish in s.dishes.where((d) => d.categoryId == category.id)) _DishCard(dish: dish, controller: controller),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish, required this.controller});
  final Dish dish;
  final FoodFlowController controller;

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeBg, badgeFg) = dish.stockBadge;

    Widget miniSwitch(bool value, VoidCallback onTap) => InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 20,
            padding: const EdgeInsets.all(2),
            alignment: value ? Alignment.centerLeft : Alignment.centerRight,
            decoration: BoxDecoration(color: value ? const Color(0xFF2AA35C) : const Color(0xFFE1E5DF), borderRadius: BorderRadius.circular(11)),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(10)), child: Text(dish.emoji, style: const TextStyle(fontSize: 22))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(dish.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13))),
                    Text('${dish.price} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF176F3D))),
                  ],
                ),
                if (dish.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(dish.description, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))),
                  )
                else
                  const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: Color(badgeBg), borderRadius: BorderRadius.circular(999)),
                      child: Text(badgeLabel, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 10, color: Color(badgeFg))),
                    ),
                    const SizedBox(width: 10),
                    InkWell(onTap: () => controller.changeStock(dish, -1), child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF0F2EF), shape: BoxShape.circle), child: const Text('−', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 12)))),
                    SizedBox(width: 24, child: Text('${dish.stock}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11))),
                    InkWell(onTap: () => controller.changeStock(dish, 1), child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF0F2EF), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 12)))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(children: [const Text('متاح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF7C8574))), const SizedBox(width: 6), miniSwitch(dish.isAvailable, () => controller.toggleDishAvailable(dish))]),
                    const SizedBox(width: 14),
                    Row(children: [const Text('🛵 للتوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF7C8574))), const SizedBox(width: 6), miniSwitch(dish.availableForDelivery, () => controller.toggleDishDelivery(dish))]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
