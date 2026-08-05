import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';

/// Screen 71 — Reports.
///
/// Demo data, same as the original design — real revenue/cost/profit and
/// top-dishes need actual completed `food_orders` rows, which won't exist
/// until `request-food-order`/`respond-to-order` are built (Section 2).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);

    Widget statCard(String label, String value, {Color bg = const Color(0xFFF8F9F8), Color labelColor = const Color(0xFF7C8574), Color valueColor = const Color(0xFF1A1D16)}) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: labelColor)),
                Text(value, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15, color: valueColor)),
              ],
            ),
          ),
        );

    Widget dishRow(String name, String count) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F2EF)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
              Text(count, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF176F3D))),
            ],
          ),
        );

    Widget inventoryStat(String count, String label, Color bg, Color fg) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(count, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: fg)),
                Text(label, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10, color: fg)),
              ],
            ),
          ),
        );

    Widget inventoryRow(String emoji, String name, String meta, String badge, Color badgeBg, Color badgeFg) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F2EF)))),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(meta, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                child: Text(badge, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 10, color: badgeFg)),
              ),
            ],
          ),
        );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
      child: ListView(
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('التقارير', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('المبيعات والأرباح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 10),
          Row(
            children: [
              statCard('الإيرادات', '150,608 أوقية'),
              const SizedBox(width: 8),
              statCard('التكلفة التقديرية', '59,904 أوقية', valueColor: const Color(0xFFDC2626)),
              const SizedBox(width: 8),
              statCard('صافي الربح', '90,704 أوقية', bg: const Color(0xFFEFFBF3), labelColor: const Color(0xFF176F3D), valueColor: const Color(0xFF176F3D)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('المبيعات (آخر 7 أيام)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(painter: _BarsPainter()),
          ),
          const SizedBox(height: 14),
          const Text('الأطباق الأكثر مبيعًا', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 4),
          dishRow('بيتزا مارغريتا', '142 طلب'),
          dishRow('باستا بولونيز', '98 طلب'),
          dishRow('تيراميسو', '64 طلب'),
          const SizedBox(height: 20),
          const Text('حالة المخزون', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 10),
          Row(
            children: [
              inventoryStat('2', 'متوفر', const Color(0xFFD8F3E1), const Color(0xFF176F3D)),
              const SizedBox(width: 8),
              inventoryStat('1', 'كمية منخفضة', const Color(0xFFFFF3C4), const Color(0xFF8F660C)),
              const SizedBox(width: 8),
              inventoryStat('1', 'نفذ المخزون', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
            ],
          ),
          const SizedBox(height: 4),
          inventoryRow('🍕', 'بيتزا مارغريتا', 'الكمية المتبقية: 24 · بِيع منها 142', 'متوفر', const Color(0xFFD8F3E1), const Color(0xFF176F3D)),
          inventoryRow('🍝', 'باستا بولونيز', 'الكمية المتبقية: 6 · بِيع منها 98', 'كمية منخفضة', const Color(0xFFFFF3C4), const Color(0xFF8F660C)),
          inventoryRow('🍲', 'شوربة العدس', 'الكمية المتبقية: 0 · بِيع منها 37', 'نفذ المخزون', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
          inventoryRow('🍰', 'تيراميسو', 'الكمية المتبقية: 12 · بِيع منها 64', 'متوفر', const Color(0xFFD8F3E1), const Color(0xFF176F3D)),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  static const _heights = [60.0, 90.0, 75.0, 110.0, 70.0, 95.0, 120.0];
  static const _colors = [
    Color(0xFFB3E7C4),
    Color(0xFF82D6A0),
    Color(0xFF82D6A0),
    Color(0xFF2AA35C),
    Color(0xFF82D6A0),
    Color(0xFF2AA35C),
    Color(0xFF176F3D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (_heights.length * 1.5);
    final gap = barWidth * 0.5;
    for (var i = 0; i < _heights.length; i++) {
      final x = i * (barWidth + gap) + gap / 2;
      final h = _heights[i];
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - h, barWidth, h), const Radius.circular(4));
      canvas.drawRRect(rect, Paint()..color = _colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
