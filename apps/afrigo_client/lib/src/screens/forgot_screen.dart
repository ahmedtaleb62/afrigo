import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/client_primary_button.dart';
import '../widgets/client_text_field.dart';
import '../core/context_ext.dart';

/// Screen 7 — Forgot password: a single screen with 3 inline steps (request
/// code → verify code → set new password), matching the new design's
/// `is.forgot` + `forgot.step0/1/2`.
class ForgotScreen extends ConsumerWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final step = ref.watch(clientFlowControllerProvider.select((s) => s.forgotStep));
    final authError = ref.watch(clientFlowControllerProvider.select((s) => s.authError));

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(20), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              Text(context.l10n.clientForgotTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1C1917))),
            ],
          ),
          const SizedBox(height: 24),
          if (step == 0) _StepRequestCode(controller: controller),
          if (step == 1) _StepVerifyCode(controller: controller),
          if (step == 2) _StepNewPassword(controller: controller),
          if (authError != null) ...[
            const SizedBox(height: 12),
            Text(authError, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
        ],
      ),
    );
  }
}

class _StepRequestCode extends StatelessWidget {
  const _StepRequestCode({required this.controller});

  final ClientFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.clientForgotStep0Desc, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
        const SizedBox(height: 14),
        ClientTextField(hint: '46 12 34 56', keyboardType: TextInputType.phone, onChanged: controller.setFpPhone),
        const SizedBox(height: 20),
        ClientPrimaryButton(label: l10n.clientSendCode, onPressed: controller.sendResetCode),
      ],
    );
  }
}

class _StepVerifyCode extends StatelessWidget {
  const _StepVerifyCode({required this.controller});

  final ClientFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('✅', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 14),
        Text(l10n.clientCodeSentDesc, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1C1917))),
        const SizedBox(height: 14),
        ClientTextField(hint: l10n.clientEnterCodeHint, textAlign: TextAlign.center, onChanged: controller.setFpCode),
        const SizedBox(height: 20),
        ClientPrimaryButton(label: l10n.commonVerify, onPressed: controller.verifyResetCode),
      ],
    );
  }
}

class _StepNewPassword extends StatelessWidget {
  const _StepNewPassword({required this.controller});

  final ClientFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientTextField(label: l10n.clientNewPasswordLabel, hint: '••••••••', obscureText: true, onChanged: controller.setFpNewPassword),
        const SizedBox(height: 14),
        ClientTextField(label: l10n.clientConfirmPasswordLabel, hint: '••••••••', obscureText: true),
        const SizedBox(height: 20),
        ClientPrimaryButton(label: l10n.clientSaveAndLogin, onPressed: controller.resetPasswordDone),
      ],
    );
  }
}
