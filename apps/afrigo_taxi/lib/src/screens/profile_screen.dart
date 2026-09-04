import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/context_ext.dart';
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
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taxiDeleteAccountTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(l10n.taxiDeleteAccountMessage, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.taxiCancel, style: const TextStyle(fontFamily: 'Tajawal'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.taxiDeleteConfirm, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Color(0xFFDC2626)))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final error = await ref.read(taxiFlowControllerProvider.notifier).deleteAccount();
    if (error != null && mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.taxiDeleteFailedTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
          content: Text(error, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonOk, style: const TextStyle(fontFamily: 'Tajawal')))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final l10n = context.l10n;

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
                      _ratingCount == 0 ? l10n.taxiNoRatingsYet : l10n.taxiRatingSummary(_avgRating.toStringAsFixed(1), _ratingCount),
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
                      menuRow(l10n.taxiEditVehicleInfo, onTap: () => controller.goTo(TaxiScreen.vehicleDocs)),
                      menuRow(
                        l10n.taxiLanguageLabel,
                        onTap: () => controller.setSettingsLang(s.settingsLang == 'ar' ? 'fr' : 'ar'),
                        trailing: '${s.settingsLang == 'ar' ? 'العربية' : 'Français'} ›',
                        divider: false,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      menuRow(l10n.taxiSupportMenuLabel, onTap: () => controller.goToInfo(TaxiScreen.support)),
                      menuRow(l10n.taxiLegalAboutTitle, onTap: () => controller.goToInfo(TaxiScreen.about)),
                      menuRow(l10n.taxiLegalTermsTitle, onTap: () => controller.goToInfo(TaxiScreen.terms)),
                      menuRow(l10n.taxiLegalPrivacyTitle, onTap: () => controller.goToInfo(TaxiScreen.privacy), divider: false),
                    ],
                  ),
                ),
                InkWell(
                  onTap: controller.signOut,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.taxiLogout, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
                  ),
                ),
                InkWell(
                  onTap: _confirmDeleteAccount,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.taxiDeleteAccountTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFA8A29E))),
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
