import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/permission_request_view.dart';

/// Screen 8 — Location permission.
class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    return PermissionRequestView(
      emoji: '📍',
      title: 'تفعيل الموقع الجغرافي',
      desc: 'نحتاج موقعك لعرض الخدمات القريبة منك وتحديد نقطة انطلاقك بدقة',
      primaryLabel: 'السماح بالوصول للموقع',
      onPrimary: controller.requestLocationPermission,
      onSkip: () => controller.goTo(ClientScreen.notifPermission),
    );
  }
}
