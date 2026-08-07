import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/food_bottom_nav.dart';

/// Screens 65/66 — Home. The 2 stat cards below (orders/revenue today) are
/// demo data, same as `reports_screen.dart` — no aggregation query/RPC
/// exists yet for real per-day analytics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);
    final canOpen = !s.lowBalance;
    final isOpen = s.open && canOpen;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                  Text('${s.resolvedBalance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF166534))),
                ],
              ),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد إشعارات جديدة'))),
                borderRadius: BorderRadius.circular(12),
                child: Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(12)), child: const Text('🔔')),
              ),
            ],
          ),
        ),
        if (s.lowBalance)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFEE2E2)), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رصيدك منتهٍ، لا يمكنك استقبال طلبات جديدة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF991B1B))),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تواصل عبر واتساب: +222 45 00 00 00'))),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, padding: const EdgeInsets.all(10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('📞 تواصل مع الشركة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: InkWell(
            onTap: canOpen ? controller.toggleOpen : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: isOpen ? const Color(0xFFF0FDF4) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    canOpen ? (isOpen ? 'المطعم مفتوح لاستقبال الطلبات' : 'المطعم مغلق') : 'مغلق (رصيد غير كافٍ)',
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: isOpen ? const Color(0xFF166534) : const Color(0xFF78716C)),
                  ),
                  Opacity(
                    opacity: canOpen ? 1 : 0.6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      height: 28,
                      padding: const EdgeInsets.all(3),
                      alignment: isOpen ? Alignment.centerLeft : Alignment.centerRight,
                      decoration: BoxDecoration(color: isOpen ? const Color(0xFF16A34A) : const Color(0xFFD6D3D1), borderRadius: BorderRadius.circular(14)),
                      child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طلبات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))), Text('18', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18))]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إيرادات اليوم (أ.م)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))), Text('32,400', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18))]),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Align(alignment: Alignment.centerRight, child: Text('اختصارات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF78716C)))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _ShortcutCard(emoji: '📋', label: 'القائمة', onTap: () => controller.goTo(FoodScreen.menu))),
              const SizedBox(width: 10),
              Expanded(child: _ShortcutCard(emoji: '📊', label: 'التقارير', onTap: () => controller.goTo(FoodScreen.reports))),
            ],
          ),
        ),
        const Spacer(),
        const FoodBottomNav(current: FoodScreen.home),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.emoji, required this.label, required this.onTap});
  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
