import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';
import '../widgets/real_map.dart';

/// Screen 55 — Navigate to pickup.
class NavigateToPickupScreen extends ConsumerWidget {
  const NavigateToPickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final l10n = context.l10n;
    final clientName = s.clientName ?? '...';
    final pickupLat = s.activeRide?.pickupLat ?? s.currentLat ?? 18.0858;
    final pickupLng = s.activeRide?.pickupLng ?? s.currentLng ?? -15.9785;

    return Column(
      children: [
        Expanded(
          child: LiveMap(
            lat: pickupLat,
            lng: pickupLng,
            zoom: 15,
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: LatLng(pickupLat, pickupLng)),
              if (s.currentLat != null) Marker(markerId: const MarkerId('me'), position: LatLng(s.currentLat!, s.currentLng!), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            },
            overlay: Positioned(
              top: 54,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF1C1917), borderRadius: BorderRadius.circular(10)),
                child: Text(l10n.taxiNavToPickupBanner, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
              ),
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
                    Container(width: 48, height: 48, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('👩', style: TextStyle(fontSize: 20))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clientName, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                          if (s.clientPhone != null)
                            Text(s.clientPhone!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: s.clientPhone == null ? null : () => launchUrl(Uri(scheme: 'tel', path: s.clientPhone)),
                      customBorder: const CircleBorder(),
                      child: Container(width: 40, height: 40, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('📞', style: TextStyle(fontSize: 16))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.startTripOngoing,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: Text(l10n.taxiArrivedStartTripBtn, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: controller.cancelRide,
                  child: Text(l10n.taxiCancelTripBtn, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
