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

    return Stack(
      children: [
        Column(
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
                          onTap: s.lowBalance ? null : controller.toggleOnline,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 64,
                            height: 36,
                            padding: const EdgeInsets.all(3),
                            alignment: s.online && !s.lowBalance ? Alignment.centerLeft : Alignment.centerRight,
                            decoration: BoxDecoration(color: (s.online && !s.lowBalance) ? const Color(0xFF2AA35C) : const Color(0xFFE1E5DF), borderRadius: BorderRadius.circular(20)),
                            child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      s.lowBalance ? 'غير متصل (رصيد غير كافٍ)' : (s.online ? 'متصل — بانتظار الطلبات' : 'غير متصل'),
                      style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: (s.online && !s.lowBalance) ? const Color(0xFF82D6A0) : const Color(0xFFB3E7C4)),
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
                      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('توصيلات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))), Text('11', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20))]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F1A1D16), blurRadius: 3)]),
                      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أرباح اليوم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))), Text('1,540 أوقية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20))]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: MapPlaceholder(borderRadius: BorderRadius.circular(16), child: const MapCenterPin()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextButton(
                onPressed: controller.toggleLowBalanceDemo,
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFF0F2EF), padding: const EdgeInsets.all(12)),
                child: Text(s.lowBalance ? 'معاينة: رصيد كافٍ' : 'معاينة: رصيد منخفض', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1A1D16))),
              ),
            ),
            const LivreurBottomNav(current: LivreurScreen.home),
          ],
        ),
        if (s.incomingOffer != null)
          Positioned.fill(
            child: Container(
              color: const Color(0x660F3F23),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('طلب توصيل جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                          child: Text('${s.incomingCountdown}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(alignment: Alignment.centerRight, child: Text('الاستلام: ${s.incomingOffer!.pickupLabel}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF7C8574)))),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'التسليم: ${s.incomingOffer!.dropoffLabel}'
                        '${s.incomingOffer!.distanceKm != null ? ' · ${s.incomingOffer!.distanceKm!.toStringAsFixed(1)} كم' : ''}',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF7C8574)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(s.incomingOffer!.price ?? 0).toStringAsFixed(0)} أوقية تقديريًا',
                        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF176F3D)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: controller.rejectIncoming,
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.all(15)),
                            child: const Text('رفض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFDC2626))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: controller.acceptIncoming,
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFF2AA35C), padding: const EdgeInsets.all(15)),
                            child: const Text('قبول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
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
