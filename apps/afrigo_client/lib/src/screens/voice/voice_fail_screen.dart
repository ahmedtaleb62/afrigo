import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/client_primary_button.dart';
import '../../core/context_ext.dart';

/// Screen 39 — Voice ordering failed.
class VoiceFailScreen extends ConsumerWidget {
  const VoiceFailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(clientFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('🤔', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(l10n.clientVoiceFailTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(l10n.clientVoiceFailDesc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
          const Spacer(),
          ClientPrimaryButton(label: l10n.commonRetry, onPressed: () => controller.goTo(ClientScreen.voiceRecord, patch: (s) => s.copyWith(voiceStage: VoiceStage.idle))),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.goTo(ClientScreen.home),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.all(16)),
              child: Text(l10n.clientVoiceFailManualContinue, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1C1917))),
            ),
          ),
        ],
      ),
    );
  }
}
