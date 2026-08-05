import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/taxi_bottom_nav.dart';

/// Screen 60 — Profile/Settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);

    Widget menuRow(String label, {VoidCallback? onTap, String trailing = '›', bool divider = true}) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
                Text(trailing, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFFA8A29E))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFFAFAF9),
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 20),
              children: [
                Column(
                  children: [
                    Container(width: 76, height: 76, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle), child: const Text('🧔', style: TextStyle(fontSize: 30))),
                    const SizedBox(height: 10),
                    const Text('مراد بلحاج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    const Text('⭐ 4.8 · 312 رحلة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      menuRow('تعديل بيانات المركبة', onTap: () => controller.goTo(TaxiScreen.vehicleDocs)),
                      menuRow('اللغة', trailing: 'عربي ›', divider: false),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  child: const Column(children: [_StaticRow('الإشعارات'), _StaticRow('الدعم والمساعدة', divider: false)]),
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
        const TaxiBottomNav(current: TaxiScreen.profile),
      ],
    );
  }
}

class _StaticRow extends StatelessWidget {
  const _StaticRow(this.label, {this.divider = true});
  final String label;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
          const Text('›', style: TextStyle(color: Color(0xFFA8A29E))),
        ],
      ),
    );
  }
}
