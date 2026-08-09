import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_primary_button.dart';
import '../core/context_ext.dart';

/// Screen 2 — Language select.
class LangSelectScreen extends ConsumerWidget {
  const LangSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final langPick = ref.watch(clientFlowControllerProvider.select((s) => s.langPick));

    Widget option({required String label, required String value, required TextDirection dir, required TextStyle style}) {
      final selected = langPick == value;
      return InkWell(
        onTap: () => controller.pickLang(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: 2),
            color: selected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Directionality(
            textDirection: dir,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: style),
                Text(selected ? '✅' : '', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اختر لغتك', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 6),
          const Text('Choisissez votre langue', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF78716C))),
          const SizedBox(height: 32),
          option(
            label: 'العربية',
            value: 'ar',
            dir: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          option(
            label: 'Français',
            value: 'fr',
            dir: TextDirection.ltr,
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(),
          ClientPrimaryButton(label: context.l10n.commonContinue, onPressed: () => controller.goTo(ClientScreen.onboarding)),
        ],
      ),
    );
  }
}
