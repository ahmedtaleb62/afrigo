import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/food_bottom_nav.dart';

/// Screen 72 — Profile/Settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final deliveryLabel = ref.watch(foodFlowControllerProvider.select((s) => s.deliveryMethodLabel));

    Widget menuRow(String label, {VoidCallback? onTap, bool divider = true}) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF0F2EF))) : null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
                const Text('›', style: TextStyle(color: Color(0xFFA3AB9C))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9F8),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
              children: [
                Column(
                  children: [
                    Container(width: 76, height: 76, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFFFF3C4), shape: BoxShape.circle), child: const Text('🍕', style: TextStyle(fontSize: 30))),
                    const SizedBox(height: 10),
                    const Text('مطعم بيت الطليان', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    const Text('⭐ 4.7 · إيطالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF7C8574))),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFEFFBF3), borderRadius: BorderRadius.circular(999)),
                      child: Text('🚚 $deliveryLabel', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF176F3D))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      menuRow('تعديل بيانات المطعم', onTap: () => controller.goTo(FoodScreen.restaurantDocs)),
                      menuRow('تعديل بيانات الدراجة', onTap: () => controller.goTo(FoodScreen.bikeDocs)),
                      menuRow('إعدادات التوصيل والتسعير', onTap: () => controller.goTo(FoodScreen.deliverySettings), divider: false),
                    ],
                  ),
                ),
                InkWell(
                  onTap: controller.signOut,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                  ),
                ),
              ],
            ),
          ),
        ),
        const FoodBottomNav(current: FoodScreen.profile),
      ],
    );
  }
}
