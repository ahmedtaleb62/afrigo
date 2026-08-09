import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/simple_prompt_dialog.dart';
import '../core/context_ext.dart';

const _labelEmoji = {'home': '🏠', 'work': '💼', 'other': '📍'};

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
    final l10n = context.l10n;
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final labelText = {'home': l10n.clientSettingsAddressHome, 'work': l10n.clientSettingsAddressWork, 'other': l10n.clientSettingsAddressOther};

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
                '${_labelEmoji[label] ?? '📍'} ${labelText[label] ?? l10n.clientSettingsAddressOther} — ${addr['address']}',
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
              Text(l10n.clientSettingsTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          row(
            label: Text(l10n.clientSettingsLanguage, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: Row(children: [langChip('عربي', 'ar'), const SizedBox(width: 6), langChip('Français', 'fr')]),
          ),
          row(
            label: Text(l10n.clientSettingsNotifications, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
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
                Text(l10n.clientSettingsSavedAddresses, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
                const SizedBox(height: 10),
                if (s.savedAddressesLoading)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                else
                  for (final a in s.savedAddresses) addressRow(a),
                InkWell(
                  onTap: () async {
                    final text = await SimplePromptDialog.showTextPrompt(
                      context,
                      title: l10n.clientSettingsNewAddressTitle,
                      hint: l10n.clientSettingsNewAddressHint,
                      confirmLabel: l10n.clientSettingsAddConfirm,
                    );
                    if (text != null && text.trim().isNotEmpty) await controller.addSavedAddress('other', text);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l10n.clientSettingsAddAddress, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
                  ),
                ),
              ],
            ),
          ),
          linkRow(l10n.clientSettingsAbout, onTap: () => controller.goToInfo(ClientScreen.about)),
          linkRow(l10n.clientSettingsTerms, onTap: () => controller.goToInfo(ClientScreen.terms)),
          linkRow(l10n.clientSettingsPrivacy, onTap: () => controller.goToInfo(ClientScreen.privacy)),
          InkWell(
            onTap: controller.signOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.clientSettingsLogout, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFDC2626))),
            ),
          ),
          InkWell(
            onTap: () async {
              final confirmed = await SimplePromptDialog.showConfirm(
                context,
                title: l10n.clientSettingsDeleteAccountTitle,
                message: l10n.clientSettingsDeleteAccountMessage,
                confirmLabel: l10n.clientSettingsDeleteAccountConfirm,
                danger: true,
              );
              if (!confirmed || !context.mounted) return;
              final error = await controller.deleteAccount();
              if (error != null && context.mounted) {
                SimplePromptDialog.showInfo(context, title: l10n.clientSettingsDeleteFailedTitle, body: error);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              child: Text(l10n.clientSettingsDeleteAccountLink, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFA8A29E))),
            ),
          ),
        ],
      ),
    );
  }
}
