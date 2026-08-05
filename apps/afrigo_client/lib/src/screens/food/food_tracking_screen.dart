import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

/// Screen 29 — Food order tracking (4-step stepper).
class FoodTrackingScreen extends ConsumerWidget {
  const FoodTrackingScreen({super.key});

  static const _active = Color(0xFF16A34A);
  static const _inactive = Color(0xFFE7E5E4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(clientFlowControllerProvider);
    final stage = s.foodStage;
    final lat = s.dropoffLat ?? s.pickupLat ?? s.currentLat ?? 18.0858;
    final lng = s.dropoffLng ?? s.pickupLng ?? s.currentLng ?? -15.9785;

    final prepDone = const {FoodStage.preparing, FoodStage.ready, FoodStage.onway}.contains(stage);
    final readyDone = const {FoodStage.ready, FoodStage.onway}.contains(stage);
    final onWay = stage == FoodStage.onway;

    Widget step(String label, Color bg, String icon) => Expanded(
          child: Column(
            children: [
              Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Text(icon, style: const TextStyle(fontSize: 13, color: Colors.white))),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10)),
            ],
          ),
        );

    Widget bar(Color color) => Expanded(child: Container(height: 2, color: color, margin: const EdgeInsets.only(bottom: 16)));

    // Status text only — the client watches the restaurant/livreur advance
    // these stages live via Realtime (`_subscribeFoodOrderTracking`), it
    // never drives them itself.
    const labels = {
      FoodStage.waiting: 'بانتظار قبول المطعم',
      FoodStage.accepted: 'المطعم يحضّر طلبك',
      FoodStage.preparing: 'المطعم يحضّر طلبك',
      FoodStage.ready: 'جارٍ البحث عن مندوب توصيل',
      FoodStage.onway: 'مندوب التوصيل في الطريق إليك',
      FoodStage.delivered: 'تم التسليم',
    };

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تتبّع الطلب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    step('تم القبول', _active, '✓'),
                    bar(_active),
                    step('قيد التحضير', prepDone ? _active : _inactive, prepDone ? '✓' : '2'),
                    bar(prepDone ? _active : _inactive),
                    step('جاهز', readyDone ? _active : _inactive, readyDone ? '✓' : '3'),
                    bar(readyDone ? _active : _inactive),
                    step('في الطريق', onWay ? _active : _inactive, onWay ? '🏍️' : '4'),
                  ],
                ),
              ],
            ),
          ),
          if (onWay)
            Expanded(
              child: LiveMapPreview(
                lat: lat,
                lng: lng,
                zoom: 15,
                markers: {Marker(markerId: const MarkerId('delivery'), position: LatLng(lat, lng))},
              ),
            )
          else
            const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFF1C1917), borderRadius: BorderRadius.circular(14)),
              child: Text(
                labels[stage] ?? 'متابعة',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
