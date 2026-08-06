import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/real_map.dart';

/// Screen 17 — Provider found. A brief "matched!" confirmation before the
/// client moves on to the real live-tracking screen — auto-advances after
/// a few seconds so a client who doesn't tap "متابعة" still ends up on the
/// screen that actually shows the driver's live position moving (this one
/// only shows a static map centered on the pickup point).
class ProviderFoundScreen extends ConsumerStatefulWidget {
  const ProviderFoundScreen({super.key});

  @override
  ConsumerState<ProviderFoundScreen> createState() => _ProviderFoundScreenState();
}

class _ProviderFoundScreenState extends ConsumerState<ProviderFoundScreen> {
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _autoAdvance = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      // A cancellation landing during `AnimatedSwitcher`'s crossfade can
      // fire between this check and the timer being scheduled — `mounted`
      // alone doesn't catch it, since the old screen stays mounted through
      // the transition. `activeOrderId` is cleared the instant a
      // cancellation is processed (see `_subscribeOrderTracking`), so it's
      // the real signal that there's still an order left to track.
      if (ref.read(clientFlowControllerProvider).activeOrderId == null) return;
      ref.read(clientFlowControllerProvider.notifier).goTo(ClientScreen.tracking);
    });
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final isTaxi = s.flowType == ClientFlowType.taxi;
    final providerNoun = isTaxi ? 'سائق' : 'عامل توصيل';
    final avatar = isTaxi ? '🧔' : '🏍️';
    final name = s.providerName ?? '...';
    final vehicle = s.providerVehicle;
    final lat = s.pickupLat ?? s.currentLat ?? 18.0858;
    final lng = s.pickupLng ?? s.currentLng ?? -15.9785;

    return Column(
      children: [
        LiveMapPreview(height: 280, lat: lat, lng: lng, zoom: 15, markers: {Marker(markerId: const MarkerId('me'), position: LatLng(lat, lng))}),
        Expanded(
          child: BottomSheetPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                  child: Text('تم العثور على $providerNoun', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
                ),
                Row(
                  children: [
                    Container(width: 56, height: 56, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: Text(avatar, style: const TextStyle(fontSize: 24))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15)),
                          if (vehicle != null) Text(vehicle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: s.providerPhone == null ? null : () => launchUrl(Uri(scheme: 'tel', path: s.providerPhone)),
                      customBorder: const CircleBorder(),
                      child: Container(width: 44, height: 44, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('📞', style: TextStyle(fontSize: 18))),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _autoAdvance?.cancel();
                          controller.goTo(ClientScreen.tracking);
                        },
                        style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.all(16)),
                        child: const Text('متابعة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        _autoAdvance?.cancel();
                        controller.cancelActiveOrder();
                      },
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                      child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFDC2626))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
