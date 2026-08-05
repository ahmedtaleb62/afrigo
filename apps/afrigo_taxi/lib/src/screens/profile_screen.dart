import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/taxi_bottom_nav.dart';

/// Screen 60 — Profile/Settings.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = '...';
  double _avgRating = 0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final summary = await ref.read(taxiFlowControllerProvider.notifier).fetchMyProfileSummary();
      if (!mounted) return;
      setState(() {
        _name = summary.name;
        _avgRating = summary.avgRating;
        _ratingCount = summary.ratingCount;
      });
    });
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text('سيتم حذف حسابك وكل بياناتك نهائيًا. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('حذف نهائيًا', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Color(0xFFDC2626)))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(taxiFlowControllerProvider.notifier).deleteAccount();
    if (!ok && mounted) {
      final error = ref.read(taxiFlowControllerProvider).actionError;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذّر الحذف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
          content: Text(error ?? 'حاول مجددًا', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('حسنًا', style: TextStyle(fontFamily: 'Tajawal')))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(_name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    Text(
                      _ratingCount == 0 ? 'لا يوجد تقييمات بعد' : '⭐ ${_avgRating.toStringAsFixed(1)} · $_ratingCount رحلة مقيَّمة',
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C)),
                    ),
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
                  child: Column(
                    children: [
                      menuRow('الدعم والمساعدة', onTap: () => controller.goTo(TaxiScreen.support)),
                      menuRow('عن التطبيق', onTap: () => controller.goTo(TaxiScreen.about)),
                      menuRow('الشروط والأحكام', onTap: () => controller.goTo(TaxiScreen.terms)),
                      menuRow('سياسة الخصوصية', onTap: () => controller.goTo(TaxiScreen.privacy), divider: false),
                    ],
                  ),
                ),
                InkWell(
                  onTap: controller.signOut,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                  ),
                ),
                InkWell(
                  onTap: _confirmDeleteAccount,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: const Text('حذف الحساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFA8A29E))),
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
