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

/// Screen 18 — Live tracking. Status is real, watched via
/// `ClientFlowController._subscribeOrderTracking` — this screen never
/// drives its own transitions, it only reflects the provider's app.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
