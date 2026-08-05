import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../widgets/back_circle_button.dart';

const _statusLabel = {
  'completed': 'مكتملة',
  'cancelled_by_client': 'ملغاة',
  'cancelled_by_driver': 'ملغاة',
  'no_driver_found': 'لم يُعثر على سائق',
};

String _formatTripTime(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '';
  final now = DateTime.now();
  final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
  final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  return isToday ? 'اليوم $time' : '${d.year}/${d.month}/${d.day} $time';
}

/// Screen 59 — Trip history. Real `rides` rows for this driver
/// (`loadTripHistory`) — replaces the design's 2 hardcoded demo trips.
class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final trips = ref.watch(taxiFlowControllerProvider.select((s) => s.tripHistory));
    final loading = ref.watch(taxiFlowControllerProvider.select((s) => s.tripHistoryLoading));

    Widget trip(String name, String price, String meta) => Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(price, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF166534))),
                ],
              ),
              Text(meta, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
            ],
          ),
        );

    return Container(
      color: const Color(0xFFFAFAF9),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 12),
            child: Row(
              children: [
                BackCircleButton(onTap: controller.back),
                const SizedBox(width: 12),
                const Text('سجل الرحلات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
              ],
            ),
          ),
          Expanded(
            child: loading && trips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                    ? const Center(child: Text('لا توجد رحلات بعد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))))
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (final r in trips)
                            trip(
                              r['client_name'] as String? ?? 'زبون',
                              r['price'] == null ? (_statusLabel[r['status']] ?? r['status'] as String? ?? '') : '${(r['price'] as num).toStringAsFixed(0)} أوقية',
                              '${_formatTripTime(r['created_at'] as String?)} · ${r['distance_km'] == null ? '—' : '${(r['distance_km'] as num).toStringAsFixed(1)} كم'}',
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
