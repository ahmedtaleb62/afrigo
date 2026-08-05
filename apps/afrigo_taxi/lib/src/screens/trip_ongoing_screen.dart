import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../state/taxi_flow_controller.dart';
import '../widgets/real_map.dart';

/// Screen 56 — Trip ongoing.
class TripOngoingScreen extends ConsumerWidget {
  const TripOngoingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final dropoff = s.activeRide?.dropoffAddress ?? '...';
    final dropoffLat = s.activeRide?.dropoffLat ?? s.currentLat ?? 18.0858;
    final dropoffLng = s.activeRide?.dropoffLng ?? s.currentLng ?? -15.9785;

    return Column(
      children: [
        Expanded(
          child: LiveMap(
            lat: dropoffLat,
            lng: dropoffLng,
            zoom: 13,
            markers: {
              Marker(markerId: const MarkerId('dropoff'), position: LatLng(dropoffLat, dropoffLng), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
              if (s.currentLat != null) Marker(markerId: const MarkerId('me'), position: LatLng(s.currentLat!, s.currentLng!), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            },
            overlay: Positioned(
              top: 54,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF1C1917), borderRadius: BorderRadius.circular(10)),
                child: Text('الرحلة جارية إلى: $dropoff', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.endTripDriver,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('إنهاء الرحلة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
