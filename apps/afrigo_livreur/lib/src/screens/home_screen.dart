import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/livreur_bottom_nav.dart';
import '../state/livreur_screen.dart';

/// Screens 76/77 — Home (online switch + stats + incoming delivery sheet).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final s = ref.watch(livreurFlowControllerProvider);

    ref.listen(livreurFlowControllerProvider.select((s) => s.actionError), (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      controller.clearActionError();
    });

    final connected = s.online && !s.lowBalance;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                      Text('${s.resolvedBalance.toStringAsFixed(0)} أ.م', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1C1917))),
                    ],
                  ),
                  InkWell(
                    onTap: () => controller.goTo(LivreurScreen.wallet),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                      child: const Text('👛', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            if (s.lowBalance)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFEE2E2)), borderRadius: BorderRadius.circular(12)),
                child: const Text('رصيدك غير كافٍ لاستقبال طلبات توصيل', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF991B1B))),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: InkWell(
                onTap: s.lowBalance ? null : controller.toggleOnline,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: connected ? const Color(0xFFF0FDF4) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.lowBalance ? 'متصل غير متاح (رصيد منخفض)' : (connected ? 'متصل — تستقبل الطلبات' : 'غير متصل'),
                        style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: connected ? const Color(0xFF166534) : const Color(0xFF78716C)),
                      ),
                      Opacity(
                        opacity: s.lowBalance ? 0.6 : 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 52,
                          height: 28,
                          padding: const EdgeInsets.all(3),
                          alignment: connected ? Alignment.centerLeft : Alignment.centerRight,
                          decoration: BoxDecoration(color: connected ? const Color(0xFF16A34A) : const Color(0xFFD6D3D1), borderRadius: BorderRadius.circular(14)),
                          child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: MapPlaceholder(height: 170, borderRadius: BorderRadius.circular(16), child: const Center(child: Text('خريطة نواكشوط — موقعك الحالي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534))))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [Text('11', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18)), SizedBox(height: 2), Text('توصيلات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF78716C)))],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [Text('3300', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18)), SizedBox(height: 2), Text('أرباح اليوم (أ.م)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF78716C)))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextButton(
                onPressed: controller.toggleLowBalanceDemo,
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.all(12)),
                child: Text(s.lowBalance ? 'معاينة: رصيد كافٍ' : 'معاينة: رصيد منخفض', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1C1917))),
              ),
            ),
            LivreurBottomNav(current: LivreurScreen.home),
          ],
        ),
        if (s.incomingOffer != null)
          Positioned.fill(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 30, offset: Offset(0, -10))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('طلب توصيل جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('${s.incomingCountdown}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFFDC2626))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(alignment: Alignment.centerRight, child: Text('📍 الاستلام: ${s.incomingOffer!.pickupLabel}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13))),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: Text('🎯 التسليم: ${s.incomingOffer!.dropoffLabel}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13))),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 16,
                        children: [
                          if (s.incomingOffer!.distanceKm != null) Text('📏 ${s.incomingOffer!.distanceKm!.toStringAsFixed(1)} كم', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF57534E))),
                          Text('💰 ${(s.incomingOffer!.price ?? 0).toStringAsFixed(0)} أ.م', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF57534E))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: controller.rejectIncoming,
                            style: TextButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFDC2626), width: 2), padding: const EdgeInsets.all(13)),
                            child: const Text('رفض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFDC2626))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: controller.acceptIncoming,
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.all(15)),
                            child: const Text('قبول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
