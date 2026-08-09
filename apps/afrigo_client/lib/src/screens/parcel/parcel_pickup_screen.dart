import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

/// Screen 31 — Parcel pickup point. Real interactive map, same as
/// `ride_origin_screen`.
class ParcelPickupScreen extends ConsumerStatefulWidget {
  const ParcelPickupScreen({super.key});

  @override
  ConsumerState<ParcelPickupScreen> createState() => _ParcelPickupScreenState();
}

class _ParcelPickupScreenState extends ConsumerState<ParcelPickupScreen> {
  @override
  void initState() {
    super.initState();
    // See `ride_origin_screen.dart` — re-request on mount so a stale/never
    // -resolved GPS fix from earlier doesn't leave the pin on the
    // Nouakchott-center placeholder.
    Future.microtask(() => ref.read(clientFlowControllerProvider.notifier).fetchCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    // See `ride_origin_screen.dart` — a fresher GPS fix must win until the
    // user deliberately moves the pin, or the pickup freezes on whatever
    // `pickupLat` first auto-resolved to (possibly still the placeholder).
    final lat = s.pickupIsUserSet ? (s.pickupLat ?? s.currentLat ?? 18.0858) : (s.currentLat ?? s.pickupLat ?? 18.0858);
    final lng = s.pickupIsUserSet ? (s.pickupLng ?? s.currentLng ?? -15.9785) : (s.currentLng ?? s.pickupLng ?? -15.9785);
    final l10n = context.l10n;

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.clientParcelPickupTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('📍', style: TextStyle(color: Color(0xFF16A34A))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.pickupAddress ?? l10n.clientRideLocatingAddress, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))),
                    ],
                  ),
                ),
                ClientPrimaryButton(label: l10n.clientParcelConfirmPickupBtn, onPressed: () => controller.goTo(ClientScreen.parcelDropoff)),
              ],
            ),
        ),
      ],
    );
  }
}
