import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/food_bottom_nav.dart';

/// Screen 72 — Profile/Settings.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    final error = await ref.read(foodFlowControllerProvider.notifier).deleteAccount();
    if (error != null && mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذّر الحذف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
          content: Text(error, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('حسنًا', style: TextStyle(fontFamily: 'Tajawal')))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);
    final deliveryLabel = s.deliveryMethodLabel;

    Widget menuRow(String label, {VoidCallback? onTap, bool divider = true}) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
                const Text('›', style: TextStyle(color: Color(0xFFA8A29E))),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F4),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
              children: [
                Column(
                  children: [
                    Container(width: 76, height: 76, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFFEF9C3), shape: BoxShape.circle), child: const Text('🍕', style: TextStyle(fontSize: 30))),
                    const SizedBox(height: 10),
                    Text(s.restaurantName ?? '...', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                    Text(s.restaurantCuisineType ?? '', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(999)),
                      child: Text('🚚 $deliveryLabel', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      menuRow('تعديل بيانات المطعم', onTap: () => controller.goTo(FoodScreen.restaurantDocs)),
                      menuRow('تعديل بيانات الدراجة', onTap: () => controller.goTo(FoodScreen.bikeDocs)),
                      menuRow('إعدادات التوصيل والتسعير', onTap: () => controller.goTo(FoodScreen.deliverySettings)),
                      menuRow('أوقات العمل', onTap: () => controller.goTo(FoodScreen.workingHours), divider: false),
                    ],
                  ),
                ),
                InkWell(
                  onTap: controller.signOut,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
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
        const FoodBottomNav(current: FoodScreen.profile),
      ],
    );
  }
}
