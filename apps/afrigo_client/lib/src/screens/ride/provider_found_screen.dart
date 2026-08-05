import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/real_map.dart';

/// Screen 17 — Provider found.
class ProviderFoundScreen extends ConsumerWidget {
  const ProviderFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        onPressed: () => controller.goTo(ClientScreen.tracking),
                        style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.all(16)),
                        child: const Text('متابعة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: controller.cancelActiveOrder,
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
