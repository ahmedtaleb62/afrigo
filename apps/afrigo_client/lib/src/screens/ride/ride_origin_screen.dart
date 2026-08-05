import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

/// Screen 12 — Ride origin. Real interactive map (drag to move the pin,
/// real reverse-geocoded address) — was a static placeholder image with a
/// hardcoded address before.
class RideOriginScreen extends ConsumerWidget {
  const RideOriginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    // Until the user deliberately moves the pin, a fresher GPS fix must
    // always win over whatever `pickupLat` was auto-resolved to on mount
    // (which may still be the placeholder if GPS hadn't landed yet) —
    // otherwise the map/pickup freezes on the wrong point forever, and the
    // real ride request ends up searching for drivers around it instead of
    // the client's actual location. See `pickupIsUserSet`'s doc comment.
    final lat = s.pickupIsUserSet ? (s.pickupLat ?? s.currentLat ?? 18.0858) : (s.currentLat ?? s.pickupLat ?? 18.0858);
    final lng = s.pickupIsUserSet ? (s.pickupLng ?? s.currentLng ?? -15.9785) : (s.currentLng ?? s.pickupLng ?? -15.9785);

    return Column(
      children: [
        Expanded(
          child: LocationPickerMap(
            initialLat: lat,
            initialLng: lng,
            onChanged: controller.setPickupLocation,
            overlay: Positioned(top: context.topGap(12), right: 16, child: BackCircleButton(onTap: controller.back, onLight: true)),
          ),
        ),
        BottomSheetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('حدّد نقطة الانطلاق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('📍', style: TextStyle(color: Color(0xFF16A34A))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.pickupAddress ?? 'جارٍ تحديد الموقع...', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))),
                    ],
                  ),
                ),
                const Text('اسحب الخريطة لتعديل نقطة الانطلاق بدقة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 16),
                ClientPrimaryButton(label: 'تأكيد نقطة الانطلاق', onPressed: () => controller.goTo(ClientScreen.rideDestination)),
              ],
            ),
        ),
      ],
    );
  }
}
