import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../core/context_ext.dart';

/// Screen 32 — Parcel dropoff + recipient details. The address field now
/// does real forward geocoding — it had no `onChanged` at all before,
/// purely decorative.
class ParcelDropoffScreen extends ConsumerWidget {
  const ParcelDropoffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    Future<void> search(String query) async {
      final ok = await controller.searchDestination(query);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر العثور على هذا العنوان، جرّب صياغة أخرى')));
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('نقطة التسليم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          ClientTextField(hint: 'ابحث عن عنوان التسليم...', borderColor: const Color(0xFF16A34A), onSubmitted: search),
          if (s.dropoffAddress != null) ...[
            const SizedBox(height: 8),
            Text('✓ ${s.dropoffAddress}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF166534))),
          ],
          const SizedBox(height: 16),
          const Text('بيانات المستلم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          ClientTextField(hint: 'اسم المستلم', onChanged: controller.setRecipientName),
          const SizedBox(height: 10),
          ClientTextField(hint: 'رقم هاتف المستلم', keyboardType: TextInputType.phone, onChanged: controller.setRecipientPhone),
          const Spacer(),
          ClientPrimaryButton(label: 'متابعة', onPressed: () => controller.goTo(ClientScreen.parcelDetails)),
        ],
      ),
    );
  }
}
