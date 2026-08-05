import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../widgets/back_circle_button.dart';

/// Notifications list — real `notifications` rows, same pattern already
/// used in the Client app. The Taxi app never had this screen (or a bell
/// icon to reach it) at all before.
class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends ConsumerState<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taxiFlowControllerProvider.notifier).loadNotifications());
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);

    Widget item(Map<String, dynamic> n, {bool divider = true}) {
      final isRead = n['is_read'] == true;
      final data = n['data'] as Map<String, dynamic>?;
      final rideId = data?['ride_id'] as String?;
      final isIncomingRide = data?['type'] == 'incoming_ride' && rideId != null;
      return InkWell(
        onTap: () {
          if (!isRead) controller.markNotificationRead(n['id'] as String);
          // A push notification can be delayed or blocked by the phone's
          // own battery-saving rules — the in-app list is the reliable
          // fallback, so tapping a ride-offer row here does the exact same
          // thing tapping the push itself would: fetch it fresh and show
          // the accept/reject sheet.
          if (isIncomingRide) controller.showIncomingRideById(rideId);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRead ? '🔔' : '🟢', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n['title'] as String? ?? '', style: TextStyle(fontFamily: 'Tajawal', fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 13)),
                    Text('${n['body'] ?? ''} · ${_timeAgo(n['created_at'] as String?)}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                  ],
                ),
              ),
              if (isIncomingRide) const Text('‹', style: TextStyle(color: Color(0xFFA8A29E), fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('الإشعارات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 16),
          if (s.notificationsLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (s.notifications.isEmpty)
            const Expanded(child: EmptyState(emoji: '🔔', title: 'لا توجد إشعارات بعد', message: 'ستظهر هنا آخر التحديثات على طلباتك'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: s.notifications.length,
                itemBuilder: (_, i) => item(s.notifications[i], divider: i != s.notifications.length - 1),
              ),
            ),
        ],
      ),
    );
  }
}
