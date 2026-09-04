import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/taxi_primary_button.dart';
import '../widgets/taxi_text_field.dart';

/// Screen 46b — Driver signup. Plain form matching the original design (no
/// marketing hero) — same treatment as the login screen.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 24),
      child: ListView(
        children: [
          Row(children: [BackCircleButton(onTap: () => controller.goTo(TaxiScreen.login))]),
          const SizedBox(height: 14),
          Text(l10n.taxiSignupTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 24),
          TaxiTextField(label: l10n.taxiFullNameLabel, hint: l10n.taxiFullNameHint, onChanged: controller.setFullName),
          const SizedBox(height: 14),
          TaxiTextField(label: l10n.commonPhoneLabel, hint: l10n.taxiPhoneHint, keyboardType: TextInputType.phone, onChanged: controller.setPhone),
          const SizedBox(height: 14),
          TaxiTextField(label: l10n.commonPasswordLabel, hint: l10n.taxiPasswordHint, obscureText: true, onChanged: controller.setPassword),
          const SizedBox(height: 14),
          TaxiTextField(label: l10n.taxiConfirmPasswordLabel, hint: l10n.taxiPasswordHint, obscureText: true, onChanged: controller.setConfirmPassword),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 22),
          TaxiPrimaryButton(label: l10n.taxiCreateAccountBtn, isLoading: s.isSubmitting, onPressed: controller.doSignup),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.taxiHaveAccountPrompt, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
              InkWell(
                onTap: () => controller.goTo(TaxiScreen.login),
                child: Text(l10n.taxiLoginLink, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
