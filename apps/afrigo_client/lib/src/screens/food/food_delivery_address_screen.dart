import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/real_map.dart';
import '../../core/context_ext.dart';

/// Food checkout's delivery-address picker — was a decorative "🏠 المنزل"
/// row with an "تعديل" button that did nothing; orders always went to the
/// placeholder dropoff regardless of what was shown. Same real
/// `LocationPickerMap` pattern as ride-origin/parcel-pickup, writing to the
/// same `dropoffLat`/`dropoffLng`/`dropoffAddress` state fields
/// `placeFoodOrder` now actually reads.
class FoodDeliveryAddressScreen extends ConsumerStatefulWidget {
  const FoodDeliveryAddressScreen({super.key});

  @override
  ConsumerState<FoodDeliveryAddressScreen> createState() => _FoodDeliveryAddressScreenState();
}

class _FoodDeliveryAddressScreenState extends ConsumerState<FoodDeliveryAddressScreen> {
  // `setDropoffLocation` (shared with ride-destination/parcel-dropoff
  // search, which have no placeholder-race risk of their own) doesn't
  // track isUserAction the way `pickupIsUserSet` does, so `s.dropoffLat`
  // goes non-null the instant this screen's automatic mount-resolve fires
  // — before a real GPS fix can land. Tracked locally instead of touching
  // that shared state, so this guard can't affect the other two flows.
  bool _userMovedPin = false;

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
    final lat = s.dropoffLat ?? s.currentLat ?? 18.0858;
    final lng = s.dropoffLng ?? s.currentLng ?? -15.9785;
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          child: LocationPickerMap(
            initialLat: lat,
            initialLng: lng,
            onChanged: (lat, lng, address, {required isUserAction}) {
              if (isUserAction && !_userMovedPin) setState(() => _userMovedPin = true);
              controller.setDropoffLocation(lat, lng, address, isUserAction: isUserAction);
            },
            overlay: Positioned(top: context.topGap(12), right: 16, child: BackCircleButton(onTap: controller.back, onLight: true)),
          ),
        ),
        BottomSheetPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.clientFoodDeliveryAddressTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Text('📍', style: TextStyle(color: Color(0xFF16A34A))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.dropoffAddress ?? l10n.clientFoodLocatingMessage, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13))),
                  ],
                ),
              ),
              Text(l10n.clientFoodMapDragHint, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
              const SizedBox(height: 16),
              ClientPrimaryButton(
                label: l10n.clientFoodConfirmDeliveryAddressButton,
                // See `ride_origin_screen.dart` — without this, confirming
                // before the real GPS fix lands silently locks in the
                // Nouakchott-center placeholder as the delivery address.
                isLoading: s.currentLat == null && !_userMovedPin,
                onPressed: controller.back,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
