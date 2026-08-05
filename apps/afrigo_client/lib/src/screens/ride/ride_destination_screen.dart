import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/client_text_field.dart';
import '../../core/context_ext.dart';

/// Screen 13 — Ride destination search. The search field now does real
/// forward geocoding (`controller.searchDestination`) instead of just
/// setting a display label with no coordinates behind it; the quick-picks
/// below use real (if generic) Nouakchott coordinates for the same reason.
class RideDestinationScreen extends ConsumerWidget {
  const RideDestinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);

    Future<void> search(String query) async {
      final ok = await controller.searchDestination(query);
      if (!context.mounted) return;
      if (ok) {
        controller.goTo(ClientScreen.rideConfirm);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر العثور على هذا العنوان، جرّب صياغة أخرى')));
      }
    }

    Widget place({required String emoji, required Color bg, required String title, required String subtitle, required VoidCallback onTap, bool divider = true}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
          child: Row(
            children: [
              Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Text(emoji)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                ],
              ),
            ],
          ),
        ),
      );
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
              const Text('إلى أين تريد الذهاب؟', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          ClientTextField(hint: 'ابحث عن وجهة...', borderColor: const Color(0xFF16A34A), onChanged: controller.setRideDest, onSubmitted: search),
          const SizedBox(height: 20),
          const Text('أماكن محفوظة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 10),
          place(
            emoji: '🏠',
            bg: const Color(0xFFF0FDF4),
            title: 'المنزل',
            subtitle: 'تفرغ زينة، نواكشوط',
            onTap: () {
              controller.setDropoffLocation(18.1004, -15.9711, 'المنزل — تفرغ زينة');
              controller.goTo(ClientScreen.rideConfirm);
            },
          ),
          place(
            emoji: '💼',
            bg: const Color(0xFFFEFCE8),
            title: 'العمل',
            subtitle: 'لكصر، نواكشوط',
            onTap: () {
              controller.setDropoffLocation(18.0731, -15.9582, 'العمل — لكصر');
              controller.goTo(ClientScreen.rideConfirm);
            },
          ),
          const SizedBox(height: 14),
          const Text('آخر الوجهات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 10),
          place(
            emoji: '🕓',
            bg: const Color(0xFFF5F5F4),
            title: 'مطار نواكشوط أم التونسي الدولي',
            subtitle: 'نواكشوط',
            divider: false,
            onTap: () {
              controller.setDropoffLocation(18.3181, -15.9151, 'مطار نواكشوط أم التونسي الدولي');
              controller.goTo(ClientScreen.rideConfirm);
            },
          ),
        ],
      ),
    );
  }
}
