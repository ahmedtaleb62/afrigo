import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../widgets/real_map.dart';
import '../../widgets/payment_method_field.dart';
import '../../core/context_ext.dart';

/// Screen 14 — Ride confirm (vehicle + price + payment).
class RideConfirmScreen extends ConsumerStatefulWidget {
  const RideConfirmScreen({super.key});

  @override
  ConsumerState<RideConfirmScreen> createState() => _RideConfirmScreenState();
}

class _RideConfirmScreenState extends ConsumerState<RideConfirmScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final s = ref.read(clientFlowControllerProvider);
      ref.read(clientFlowControllerProvider.notifier).loadFareEstimate(
            serviceType: 'taxi',
            pickupLat: s.pickupLat ?? s.currentLat ?? 18.0858,
            pickupLng: s.pickupLng ?? s.currentLng ?? -15.9785,
            dropoffLat: s.dropoffLat ?? 18.0950,
            dropoffLng: s.dropoffLng ?? -15.9650,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final l10n = context.l10n;
    final destLabel = s.rideDest.isEmpty ? l10n.clientRideConfirmDestFallback : s.rideDest;
    final pickupLat = s.pickupLat ?? s.currentLat ?? 18.0858;
    final pickupLng = s.pickupLng ?? s.currentLng ?? -15.9785;
    final dropoffLat = s.dropoffLat ?? 18.0950;
    final dropoffLng = s.dropoffLng ?? -15.9650;

    final loading = s.fareEstimateLoading || s.fareEstimatePrice == null;
    final economyPrice = s.fareEstimatePrice ?? 0;
    // Comfort-tier display multiplier only — `pricing_settings` doesn't
    // track a per-vehicle-class rate yet (`rideVehicle` is plain
    // record-keeping server-side, see `client_gaps` migration), so this is
    // an honest label for a display-only markup, not a real quote.
    final comfortPrice = economyPrice * 1.35;
    // NOTE: 'مريح' here is a stored business identifier (compared against
    // `s.rideVehicle`), not display text — intentionally left untranslated.
    final selectedPrice = s.rideVehicle == 'مريح' ? comfortPrice : economyPrice;
    final distanceLabel = loading
        ? l10n.clientRideCalculatingLabel
        : l10n.clientRideDistanceDurationLabel(s.fareEstimateDistanceKm!.toStringAsFixed(1), s.fareEstimateDurationMin!.round().toString());

    Widget vehicleOption({required String emoji, required String label, required String price, required String value}) {
      final selected = s.rideVehicle == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.selectVehicle(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: 2),
              color: selected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12)),
                Text(price, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: LiveMapPreview(
            interactive: true,
            lat: (pickupLat + dropoffLat) / 2,
            lng: (pickupLng + dropoffLng) / 2,
            zoom: 12,
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: LatLng(pickupLat, pickupLng)),
              Marker(markerId: const MarkerId('dropoff'), position: LatLng(dropoffLat, dropoffLng), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
            },
            overlay: Positioned(top: context.topGap(12), right: 16, child: BackCircleButton(onTap: controller.back, onLight: true)),
          ),
        ),
        BottomSheetPanel(
          scrollable: true,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(destLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20)),
                        Text(distanceLabel, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loading ? '...' : l10n.clientRidePriceValue(selectedPrice.round().toString()),
                          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF166534)),
                        ),
                        Text(l10n.clientRideEstimatedPriceLabel, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(l10n.clientRideVehicleTypeLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // NOTE: `value:` stays the raw Arabic identifier ('اقتصادي'/'مريح')
                    // stored in state/selection logic — only `label:` (the display text) is localized.
                    vehicleOption(emoji: '🚗', label: l10n.clientRideVehicleEconomy, price: loading ? '...' : l10n.clientRidePriceValue(economyPrice.round().toString()), value: 'اقتصادي'),
                    const SizedBox(width: 10),
                    vehicleOption(emoji: '🚙', label: l10n.clientRideVehicleComfort, price: loading ? '...' : l10n.clientRidePriceValue(comfortPrice.round().toString()), value: 'مريح'),
                  ],
                ),
                const SizedBox(height: 18),
                PaymentMethodField(value: s.paymentMethod, onChanged: controller.setPaymentMethod),
                ClientTextField(hint: l10n.clientRideDriverNoteHint, onChanged: controller.setOrderNote),
                const SizedBox(height: 18),
                ClientPrimaryButton(label: l10n.clientRideOrderNowBtn, onPressed: controller.startSearch),
              ],
            ),
        ),
      ],
    );
  }
}
