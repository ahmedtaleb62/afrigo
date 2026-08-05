import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/push_notifications.dart';
import '../state/taxi_flow_controller.dart';
import '../widgets/real_map.dart';
import '../widgets/taxi_bottom_nav.dart';
import '../state/taxi_screen.dart';

extension _UnreadCount on List<Map<String, dynamic>> {
  int get unread => where((n) => n['is_read'] != true).length;
}

/// Screens 51/52 — Home (online switch + stats + incoming ride sheet).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = ref.read(taxiFlowControllerProvider.notifier);
      controller.fetchCurrentLocation();
      // Covers a session that was already logged in when the app launched
      // (persisted Supabase session, `doLogin()` never ran this process) —
      // without this, the driver could be online with no live channel ever
      // subscribed to receive incoming ride offers. Safe to call every time
      // Home mounts, including repeat visits.
      controller.ensureLiveSubscriptions();
      PushNotifications.register();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final now = DateTime.now();
    final todayTrips = s.tripHistory.where((r) {
      if (r['status'] != 'completed') return false;
      final d = DateTime.tryParse(r['completed_at'] as String? ?? '')?.toLocal();
      return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
    final todayEarnings = todayTrips.fold<double>(0, (sum, r) => sum + ((r['price'] as num?)?.toDouble() ?? 0));

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد الحالي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                      Text('${s.resolvedBalance.toStringAsFixed(0)} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF166534))),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => controller.goTo(TaxiScreen.notificationsList),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Text('🔔', style: TextStyle(fontSize: 16)),
                              if (s.notifications.unread > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => controller.goTo(TaxiScreen.wallet),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                          child: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF16A34A)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (s.lowBalance)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFEE2E2)), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('رصيدك غير كافٍ، يرجى الشحن لاستقبال الطلبات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF991B1B))),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.goTo(TaxiScreen.wallet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        child: const Text('📞 تواصل مع الشركة'),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: (s.online && !s.lowBalance) ? const Color(0xFFF0FDF4) : const Color(0xFFF5F5F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.lowBalance ? 'متصل غير متاح (رصيد منخفض)' : (s.online ? 'متصل — تستقبل الطلبات' : 'غير متصل'),
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14, color: (s.online && !s.lowBalance) ? const Color(0xFF166534) : const Color(0xFF78716C)),
                  ),
                  Opacity(
                    opacity: s.lowBalance ? 0.6 : 1,
                    child: InkWell(
                      onTap: s.lowBalance ? null : controller.toggleOnline,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 52,
                        height: 28,
                        padding: const EdgeInsets.all(3),
                        alignment: s.online && !s.lowBalance ? Alignment.centerLeft : Alignment.centerRight,
                        decoration: BoxDecoration(color: (s.online && !s.lowBalance) ? const Color(0xFF16A34A) : const Color(0xFFD6D3D1), borderRadius: BorderRadius.circular(14)),
                        child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text('${todayTrips.length}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 2), const Text('رحلات اليوم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF78716C)))]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text(todayEarnings.toStringAsFixed(0), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 2), const Text('أرباح اليوم (أ.م)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF78716C)))]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LiveMap(
                    lat: s.currentLat ?? 18.0858,
                    lng: s.currentLng ?? -15.9785,
                    zoom: 15,
                    markers: s.currentLat == null
                        ? const {}
                        : {Marker(markerId: const MarkerId('me'), position: LatLng(s.currentLat!, s.currentLng!))},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const TaxiBottomNav(current: TaxiScreen.home),
          ],
        ),
        if (s.incomingRide != null)
          Positioned.fill(
            child: Container(
              color: const Color(0x6614532D),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('طلب رحلة جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                          child: Text('${s.incomingCountdown}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(alignment: Alignment.centerRight, child: Text('من: ${s.incomingRide!.pickupAddress}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C)))),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'إلى: ${s.incomingRide!.dropoffAddress} · ${s.incomingRide!.distanceKm.toStringAsFixed(1)} كم',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${s.incomingRide!.price.toStringAsFixed(0)} أوقية تقديريًا',
                        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF166534)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: controller.rejectIncoming,
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.all(15)),
                            child: const Text('رفض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFDC2626))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: controller.acceptIncoming,
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.all(15)),
                            child: const Text('قبول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
