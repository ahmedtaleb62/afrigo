import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_primary_button.dart';
import '../widgets/client_text_field.dart';
import '../core/context_ext.dart';

/// Screen 4 — Login. Plain form matching the original design (no marketing
/// hero) — screens 10/11's own promo slider already carries the branding.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: ListView(
        children: [
          Text(l10n.clientLoginTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 26)),
          const SizedBox(height: 6),
          Text(l10n.clientLoginSubtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
          const SizedBox(height: 28),
          ClientTextField(
            label: l10n.commonPhoneLabel,
            hint: '46 12 34 56',
            keyboardType: TextInputType.phone,
            onChanged: controller.setPhone,
          ),
          const SizedBox(height: 14),
          ClientTextField(
            label: l10n.commonPasswordLabel,
            hint: '••••••••',
            obscureText: !s.showPass,
            onChanged: controller.setPassword,
            suffixIcon: IconButton(
              icon: Text(s.showPass ? '🙈' : '👁', style: const TextStyle(fontSize: 15)),
              onPressed: controller.togglePass,
            ),
          ),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: controller.goToForgot,
              child: Text(l10n.clientForgotPassword, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534))),
            ),
          ),
          const SizedBox(height: 8),
          ClientPrimaryButton(label: l10n.commonLogin, isLoading: s.isSubmitting, onPressed: controller.doLogin),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.clientNoAccountPrompt, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
              InkWell(
                onTap: () => controller.goTo(ClientScreen.signup),
                child: Text(l10n.commonCreateAccount, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
