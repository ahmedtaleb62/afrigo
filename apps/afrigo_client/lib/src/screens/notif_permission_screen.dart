import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/permission_request_view.dart';
import '../core/context_ext.dart';

/// Screen 9 — Notification permission.
class NotifPermissionScreen extends ConsumerWidget {
  const NotifPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final l10n = context.l10n;
    return PermissionRequestView(
      emoji: '🔔',
      title: l10n.clientNotifPermTitle,
      desc: l10n.clientNotifPermDesc,
      primaryLabel: l10n.clientNotifPermAllow,
      onPrimary: controller.requestNotificationPermission,
      onSkip: () => controller.goTo(ClientScreen.home),
    );
  }
}
