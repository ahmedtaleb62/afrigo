import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

/// Screen 29 — Food order tracking (4-step stepper).
class FoodTrackingScreen extends ConsumerWidget {
  const FoodTrackingScreen({super.key});

  static const _active = Color(0xFF16A34A);
  static const _inactive = Color(0xFFE7E5E4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final stage = s.foodStage;
    final isPickup = s.foodIsPickup;
    final cancelable = const {FoodStage.waiting, FoodStage.accepted, FoodStage.preparing}.contains(stage);
    final lat = s.dropoffLat ?? s.pickupLat ?? s.currentLat ?? 18.0858;
    final lng = s.dropoffLng ?? s.pickupLng ?? s.currentLng ?? -15.9785;

    final prepDone = const {FoodStage.preparing, FoodStage.ready, FoodStage.onway}.contains(stage);
    final readyDone = const {FoodStage.ready, FoodStage.onway}.contains(stage);
    final onWay = stage == FoodStage.onway;
    final l10n = context.l10n;

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
    // never drives them itself. A pickup order never reaches
    // `searching_livreur`/`out_for_delivery` at all — `ready` is its last
    // real stage, the restaurant then confirms hand-off directly.
    final labels = {
      FoodStage.waiting: l10n.clientFoodStatusWaiting,
      FoodStage.accepted: l10n.clientFoodStatusPreparing,
      FoodStage.preparing: l10n.clientFoodStatusPreparing,
      FoodStage.ready: isPickup ? l10n.clientFoodStatusReadyPickup : l10n.clientFoodStatusSearchingCourier,
      FoodStage.onway: l10n.clientFoodStatusCourierOnWay,
      FoodStage.delivered: isPickup ? l10n.clientFoodStatusPickedUp : l10n.clientFoodStatusDelivered,
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
                Row(
                  children: [
                    // Previously no way out of this screen at all short of
                    // the order finishing — a client who just wanted to
                    // check something else was trapped here. Leaving does
                    // NOT cancel the order or its subscription; the client
                    // can always get back in via "طلباتي" (order history's
                    // active tab), and the delivered-transition above no
                    // longer requires being on this screen to fire.
                    BackCircleButton(onTap: () => controller.goTo(ClientScreen.home)),
                    const SizedBox(width: 12),
                    Text(l10n.clientFoodTrackingTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    step(l10n.clientFoodStepAccepted, _active, '✓'),
                    bar(_active),
                    step(l10n.clientFoodStepPreparing, prepDone ? _active : _inactive, prepDone ? '✓' : '2'),
                    bar(prepDone ? _active : _inactive),
                    step(isPickup ? l10n.clientFoodStepReadyPickup : l10n.clientFoodStepReady, readyDone ? _active : _inactive, readyDone ? '✓' : '3'),
                    if (!isPickup) ...[
                      bar(readyDone ? _active : _inactive),
                      step(l10n.clientFoodStepOnWay, onWay ? _active : _inactive, onWay ? '🏍️' : '4'),
                    ],
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF1C1917), borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    labels[stage] ?? l10n.clientFoodStatusFallback,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                  ),
                ),
                // `providerPhone` is the livreur's number once one is
                // assigned, else falls back to the restaurant's client-facing
                // support number (`restaurants.contact_phone`) — see
                // `_fetchFoodOrderContact`.
                if (s.providerPhone != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => launchUrl(Uri(scheme: 'tel', path: s.providerPhone)),
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFF0FDF4), padding: const EdgeInsets.all(14)),
                      child: Text(l10n.clientFoodCallButtonLabel(s.providerName ?? l10n.clientFoodDefaultProviderName), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
                    ),
                  ),
                ],
                if (cancelable) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: controller.cancelFoodOrder,
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.all(14)),
                      child: Text(l10n.clientFoodCancelOrderButton, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
