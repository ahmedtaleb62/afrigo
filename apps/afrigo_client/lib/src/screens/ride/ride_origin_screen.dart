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
class RideOriginScreen extends ConsumerStatefulWidget {
  const RideOriginScreen({super.key});

  @override
  ConsumerState<RideOriginScreen> createState() => _RideOriginScreenState();
}

class _RideOriginScreenState extends ConsumerState<RideOriginScreen> {
  @override
  void initState() {
    super.initState();
    // A GPS fix requested back at Home (or during onboarding) may still be
    // unresolved or long stale by the time the client actually opens this
    // screen — re-requesting here is what makes `LocationPickerMap`'s
    // `didUpdateWidget` re-center onto the real fix instead of leaving the
    // pin sitting on the Nouakchott-center placeholder the whole time.
    Future.microtask(() => ref.read(clientFlowControllerProvider.notifier).fetchCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.clientRideOriginTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Text('📍', style: TextStyle(color: Color(0xFF16A34A))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.pickupAddress ?? l10n.clientRideLocatingAddress, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))),
                    ],
                  ),
                ),
                Text(l10n.clientRideOriginDragHint, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 16),
                ClientPrimaryButton(
                  label: l10n.clientRideOriginConfirmBtn,
                  // Without this, confirming the instant this screen mounts
                  // — before `fetchCurrentLocation()` above has resolved —
                  // silently locks in the Nouakchott-center placeholder as
                  // the real pickup point for a client who's nowhere near
                  // it. Once the user deliberately drags the pin
                  // (`pickupIsUserSet`), that's a real choice and confirming
                  // immediately is fine either way.
                  isLoading: s.currentLat == null && !s.pickupIsUserSet,
                  onPressed: () => controller.goTo(ClientScreen.rideDestination),
                ),
              ],
            ),
        ),
      ],
    );
  }
}
