import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/permission_request_view.dart';

/// Screen 9 — Notification permission.
class NotifPermissionScreen extends ConsumerWidget {
  const NotifPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    return PermissionRequestView(
      emoji: '🔔',
      title: 'تفعيل الإشعارات',
      desc: 'ابقَ على اطلاع بحالة طلباتك، عروض خاصة، وتحديثات مهمة',
      primaryLabel: 'تفعيل الإشعارات',
      onPrimary: controller.requestNotificationPermission,
      onSkip: () => controller.goTo(ClientScreen.home),
    );
  }
}
