import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_sheet_panel.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/real_map.dart';
import '../../widgets/payment_method_field.dart';
import '../../core/context_ext.dart';

/// Screen 34 — Parcel confirm + estimated price.
class ParcelConfirmScreen extends ConsumerStatefulWidget {
  const ParcelConfirmScreen({super.key});

  @override
  ConsumerState<ParcelConfirmScreen> createState() => _ParcelConfirmScreenState();
}

class _ParcelConfirmScreenState extends ConsumerState<ParcelConfirmScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final s = ref.read(clientFlowControllerProvider);
      ref.read(clientFlowControllerProvider.notifier).loadFareEstimate(
            serviceType: 'delivery',
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
    final parcelType = s.parcelType;
    final paymentMethod = s.paymentMethod;
    final pickupLat = s.pickupLat ?? s.currentLat ?? 18.0858;
    final pickupLng = s.pickupLng ?? s.currentLng ?? -15.9785;
    final dropoffLat = s.dropoffLat ?? 18.0950;
    final dropoffLng = s.dropoffLng ?? -15.9650;

    final loading = s.fareEstimateLoading || s.fareEstimatePrice == null;
    final distanceLabel = loading
        ? '...جارٍ الحساب'
        : '${s.fareEstimateDistanceKm!.toStringAsFixed(1)} كم · ${s.fareEstimateDurationMin!.round()} دقيقة تقريبًا';
    final priceLabel = loading ? '...' : '${s.fareEstimatePrice!.round()} أوقية';

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
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طرد $parcelType', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                        Text(distanceLabel, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(priceLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF166534))),
                        const Text('سعر تقديري', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PaymentMethodField(value: paymentMethod, onChanged: controller.setPaymentMethod),
                const SizedBox(height: 8),
                ClientPrimaryButton(label: 'اطلب الآن', onPressed: controller.startSearch),
              ],
            ),
        ),
      ],
    );
  }
}
