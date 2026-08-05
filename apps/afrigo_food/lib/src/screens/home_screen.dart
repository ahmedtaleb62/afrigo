import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/food_bottom_nav.dart';

/// Screens 65/66 — Home.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    Widget menuRow(String emoji, String label, VoidCallback onTap, {Widget? trailing}) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$emoji $label', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                trailing ?? const Text('›', style: TextStyle(color: Color(0xFFA3AB9C))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF0F3F23),
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('رصيدك الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFFB3E7C4))),
                      Text('${s.resolvedBalance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                    ],
                  ),
                  Opacity(
                    opacity: s.lowBalance ? 0.5 : 1,
                    child: InkWell(
                      onTap: s.lowBalance ? null : controller.toggleOpen,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 64,
                        height: 36,
                        padding: const EdgeInsets.all(3),
                        alignment: s.open && !s.lowBalance ? Alignment.centerLeft : Alignment.centerRight,
                        decoration: BoxDecoration(color: (s.open && !s.lowBalance) ? const Color(0xFF2AA35C) : const Color(0xFFE1E5DF), borderRadius: BorderRadius.circular(20)),
                        child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  s.lowBalance ? 'مغلق (رصيد غير كافٍ)' : (s.open ? 'مفتوح لاستقبال الطلبات' : 'مغلق'),
                  style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: (s.open && !s.lowBalance) ? const Color(0xFF82D6A0) : const Color(0xFFB3E7C4)),
                ),
              ),
            ],
          ),
        ),
        if (s.lowBalance)
          Container(
            width: double.infinity,
            color: const Color(0xFFFEE2E2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: const Text('رصيدك غير كافٍ، يرجى شحن رصيدك لاستقبال الطلبات', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFDC2626))),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F1A1D16), blurRadius: 3)]),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طلبات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))), Text('18', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20))]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F1A1D16), blurRadius: 3)]),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إيرادات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))), Text('14,200 أوقية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20))]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                menuRow('📋', 'إدارة القائمة', () => controller.goTo(FoodScreen.menu)),
                menuRow(
                  '🧾',
                  'الطلبات الواردة',
                  () => controller.goTo(FoodScreen.orders),
                  trailing: s.newOrders.isEmpty
                      ? null
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF5C518), borderRadius: BorderRadius.circular(999)),
                          child: Text('${s.newOrders.length} جديد', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                ),
                menuRow('📊', 'التقارير', () => controller.goTo(FoodScreen.reports)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: TextButton(
            onPressed: controller.toggleLowBalanceDemo,
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFF0F2EF), padding: const EdgeInsets.all(12)),
            child: Text(s.lowBalance ? 'معاينة: رصيد كافٍ' : 'معاينة: رصيد منخفض', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1A1D16))),
          ),
        ),
        const FoodBottomNav(current: FoodScreen.home),
      ],
    );
  }
}
