import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';
import '../widgets/taxi_primary_button.dart';

/// Screen 57 — Trip end summary (with commission breakdown).
class TripEndSummaryScreen extends ConsumerWidget {
  const TripEndSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final l10n = context.l10n;
    final ride = s.activeRide;
    final commissionPct = s.commissionPct ?? 0;
    final commission = (ride?.price ?? 0) * commissionPct / 100;

    Widget row(String label, String value, {bool big = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: big ? 14 : 13, fontWeight: big ? FontWeight.w800 : FontWeight.w400, color: big ? const Color(0xFF1C1917) : const Color(0xFF78716C))),
              Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1C1917))),
            ],
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 24),
      child: Column(
        children: [
          Column(children: [const Text('✅', style: TextStyle(fontSize: 44)), const SizedBox(height: 8), Text(l10n.taxiTripEndTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18))]),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFFAFAF9), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                row(l10n.taxiDistanceLabel, l10n.taxiDistanceKmValue((ride?.distanceKm ?? 0).toStringAsFixed(1))),
                row(l10n.taxiDurationLabel, l10n.taxiDurationMinValue((ride?.durationMin ?? 0).toStringAsFixed(0))),
                row(l10n.taxiTotalPriceLabel, l10n.taxiAmountMru((ride?.price ?? 0).toStringAsFixed(0))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.taxiCommissionDeductedLabel(commissionPct.toStringAsFixed(0)), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('-${l10n.taxiAmountMru(commission.toStringAsFixed(0))}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFDC2626))),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          TaxiPrimaryButton(label: l10n.taxiCashReceivedBtn, onPressed: controller.payReceivedCash),
        ],
      ),
    );
  }
}
