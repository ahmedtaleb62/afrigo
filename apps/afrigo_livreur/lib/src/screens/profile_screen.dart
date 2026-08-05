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

    Widget menuRow(String label, {VoidCallback? onTap, String trailing = '›', bool divider = true}) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF0F2EF))) : null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
                Text(trailing, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFFA3AB9C))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9F8),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
              children: [
                Column(
                  children: [
                    Container(width: 76, height: 76, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFEFFBF3), shape: BoxShape.circle), child: const Text('🏍️', style: TextStyle(fontSize: 30))),
                    const SizedBox(height: 10),
                    const Text('ياسين شريف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    const Text('⭐ 4.9 · 480 توصيلة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF7C8574))),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      menuRow('تعديل بيانات المركبة', onTap: () => controller.goTo(LivreurScreen.vehicleDocs)),
                      menuRow('اللغة', trailing: 'عربي ›', divider: false),
                    ],
                  ),
                ),
                InkWell(
                  onTap: controller.signOut,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                  ),
                ),
              ],
            ),
          ),
        ),
        const LivreurBottomNav(current: LivreurScreen.profile),
      ],
    );
  }
}
