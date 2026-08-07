import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../state/livreur_screen.dart';
import '../widgets/livreur_bottom_nav.dart';

/// Screen 82 — Profile/Settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);

    Widget menuRow(String label, {VoidCallback? onTap, String trailing = '‹', Color borderColor = const Color(0xFFE7E5E4), Color textColor = const Color(0xFF1C1917)}) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                Text(trailing, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFFA8A29E))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
              children: [
                Column(
                  children: [
                    Container(width: 76, height: 76, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle), child: const Text('🏍️', style: TextStyle(fontSize: 30))),
                    const SizedBox(height: 10),
                    const Text('ياسين شريف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                      child: const Text('موثّق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                menuRow('🏍️ تعديل بيانات المركبة', onTap: () => controller.goTo(LivreurScreen.vehicleDocs)),
                menuRow('💬 الدعم والمساعدة'),
                const SizedBox(height: 6),
                menuRow('تسجيل الخروج', onTap: controller.signOut, trailing: '', borderColor: const Color(0xFFFEE2E2), textColor: const Color(0xFFDC2626)),
              ],
            ),
          ),
        ),
        LivreurBottomNav(current: LivreurScreen.profile),
      ],
    );
  }
}
