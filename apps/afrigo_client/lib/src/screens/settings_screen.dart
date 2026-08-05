import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/simple_prompt_dialog.dart';
import '../core/context_ext.dart';

const _labelEmoji = {'home': '🏠', 'work': '💼', 'other': '📍'};
const _labelText = {'home': 'المنزل', 'work': 'العمل', 'other': 'عنوان'};

/// Screen 42 — Settings.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientFlowControllerProvider.notifier).loadSavedAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    Widget row({required Widget label, required Widget trailing, bool divider = true}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [label, trailing]),
        );

    Widget langChip(String label, String value) {
      final selected = s.settingsLang == value;
      return InkWell(
        onTap: () => controller.setSettingsLang(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: selected ? const Color(0xFF16A34A) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: selected ? Colors.white : const Color(0xFF78716C))),
        ),
      );
    }

    Widget addressRow(Map<String, dynamic> addr) {
      final label = addr['label'] as String? ?? 'other';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${_labelEmoji[label] ?? '📍'} ${_labelText[label] ?? 'عنوان'} — ${addr['address']}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            InkWell(
              onTap: () => controller.deleteSavedAddress(addr['id'] as String),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('✕', style: TextStyle(color: Color(0xFFA8A29E), fontSize: 13)),
              ),
            ),
          ],
        ),
      );
    }

    Widget linkRow(String label, {VoidCallback? onTap}) => InkWell(
          onTap: onTap,
          child: row(
            label: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: const Text('›', style: TextStyle(color: Color(0xFFA8A29E))),
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
      child: ListView(
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              const Text('الإعدادات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          row(
            label: const Text('اللغة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: Row(children: [langChip('عربي', 'ar'), const SizedBox(width: 6), langChip('Français', 'fr')]),
          ),
          row(
            label: const Text('الإشعارات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: InkWell(
              onTap: controller.toggleNotif,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 28,
                padding: const EdgeInsets.all(2),
                alignment: s.notifEnabled ? Alignment.centerLeft : Alignment.centerRight,
                decoration: BoxDecoration(color: s.notifEnabled ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), borderRadius: BorderRadius.circular(16)),
                child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F4)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('العناوين المحفوظة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 10),
                if (s.savedAddressesLoading)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                else
                  for (final a in s.savedAddresses) addressRow(a),
                InkWell(
                  onTap: () async {
                    final text = await SimplePromptDialog.showTextPrompt(
                      context,
                      title: 'عنوان جديد',
                      hint: 'مثال: تفرغ زينة، نواكشوط',
                      confirmLabel: 'إضافة',
                    );
                    if (text != null && text.trim().isNotEmpty) await controller.addSavedAddress('other', text);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('+ إضافة عنوان جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
                  ),
                ),
              ],
            ),
          ),
          linkRow('عن التطبيق', onTap: () => controller.goTo(ClientScreen.about)),
          linkRow('الشروط والأحكام', onTap: () => controller.goTo(ClientScreen.terms)),
          linkRow('سياسة الخصوصية', onTap: () => controller.goTo(ClientScreen.privacy)),
          InkWell(
            onTap: controller.signOut,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
            ),
          ),
          InkWell(
            onTap: () async {
              final confirmed = await SimplePromptDialog.showConfirm(
                context,
                title: 'حذف الحساب',
                message: 'سيتم حذف حسابك وكل بياناتك نهائيًا. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟',
                confirmLabel: 'حذف نهائيًا',
                danger: true,
              );
              if (!confirmed || !context.mounted) return;
              final ok = await controller.deleteAccount();
              if (!ok && context.mounted) {
                SimplePromptDialog.showInfo(context, title: 'تعذّر الحذف', body: ref.read(clientFlowControllerProvider).requestError ?? 'حاول مجددًا');
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 16),
              child: Text('حذف الحساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFA8A29E))),
            ),
          ),
        ],
      ),
    );
  }
}
