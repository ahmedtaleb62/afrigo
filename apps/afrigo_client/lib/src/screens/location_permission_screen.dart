import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/permission_request_view.dart';
import '../core/context_ext.dart';

/// Screen 8 — Location permission.
class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final l10n = context.l10n;
    return PermissionRequestView(
      emoji: '📍',
      title: l10n.clientLocationPermTitle,
      desc: l10n.clientLocationPermDesc,
      primaryLabel: l10n.clientLocationPermAllow,
      onPrimary: controller.requestLocationPermission,
      onSkip: () => controller.goTo(ClientScreen.notifPermission),
    );
  }
}
