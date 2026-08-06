import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

const _statusLabels = {
  'driver_arriving': 'السائق في طريقه إليك',
  'in_progress': 'رحلتك جارية الآن',
  'picked_up': 'استلم مندوبك طردك، في الطريق للتسليم',
};

/// Driver location broadcasts normally arrive every ~5s (see the taxi
/// app's `_startBroadcastingLocation`) — anything quieter than this for a
/// while means updates have actually stopped (backgrounded app,
/// connectivity loss), not just a single missed ping.
const _staleAfter = Duration(seconds: 25);

/// Screen 18 — Live tracking. Status is real, watched via
/// `ClientFlowController._subscribeOrderTracking` — this screen never
/// drives its own transitions, it only reflects the provider's app.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  Timer? _staleCheckTicker;

  @override
  void initState() {
    super.initState();
    // Nothing about staleness changes `ClientFlowState` on its own (no new
    // broadcast = no state change), so without a ticker forcing a rebuild
    // the "لم يصل تحديث منذ..." banner would only ever appear the instant
    // a fresh update happens to arrive, defeating its whole purpose.
    _staleCheckTicker = Timer.periodic(const Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _staleCheckTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(clientFlowControllerProvider);
    final isTaxi = s.flowType == ClientFlowType.taxi;
    final avatar = isTaxi ? '🧔' : '🏍️';
    final name = s.providerName ?? '...';
    final status = _statusLabels[s.activeOrderStatus] ?? (isTaxi ? 'في الطريق إليك' : 'في الطريق لاستلام الطرد');
    final pickupLat = s.pickupLat ?? s.currentLat ?? 18.0858;
    final pickupLng = s.pickupLng ?? s.currentLng ?? -15.9785;
    final hasLiveDriver = s.driverLat != null;
    final lat = s.driverLat ?? pickupLat;
    final lng = s.driverLng ?? pickupLng;
    final updatedAt = s.driverLocationUpdatedAt;
    final isStale = hasLiveDriver && updatedAt != null && DateTime.now().difference(updatedAt) > _staleAfter;

    return Column(
      children: [
        Expanded(
          child: LiveMapPreview(
            interactive: true,
            lat: lat,
            lng: lng,
            zoom: 15,
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: LatLng(pickupLat, pickupLng)),
              if (hasLiveDriver)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: LatLng(s.driverLat!, s.driverLng!),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
            },
            overlay: Stack(
              children: [
                Positioned(
                  top: context.topGap(12),
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF14532D), borderRadius: BorderRadius.circular(10)),
                        child: Text(status, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: const Text('🔗 مشاركة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                if (isStale)
                  Positioned(
                    top: context.topGap(56),
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFEE2E2))),
                      child: Text(
                        isTaxi ? 'تعذّر تحديث موقع السائق مؤخرًا — قد يكون في نفق أو منطقة ضعيفة التغطية' : 'تعذّر تحديث موقع المندوب مؤخرًا — قد يكون في منطقة ضعيفة التغطية',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(width: 48, height: 48, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: Text(avatar, style: const TextStyle(fontSize: 20))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: s.providerPhone == null ? null : () => launchUrl(Uri(scheme: 'tel', path: s.providerPhone)),
                      customBorder: const CircleBorder(),
                      child: Container(width: 40, height: 40, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('📞', style: TextStyle(fontSize: 16))),
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
