import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/client_primary_button.dart';
import '../widgets/client_text_field.dart';
import '../core/context_ext.dart';

/// Screen 5 — Signup. Plain form matching the original design (no
/// marketing hero) — same treatment as the login screen.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(20), 24, 24),
      child: ListView(
        children: [
          Row(children: [BackCircleButton(onTap: () => controller.goTo(ClientScreen.login))]),
          const SizedBox(height: 14),
          const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 24),
          ClientTextField(label: 'الاسم الكامل', hint: 'مثال: سارة بن علي', onChanged: controller.setFullName),
          const SizedBox(height: 14),
          ClientTextField(label: 'رقم الهاتف', hint: '46 12 34 56', keyboardType: TextInputType.phone, onChanged: controller.setPhone),
          const SizedBox(height: 14),
          ClientTextField(label: 'كلمة المرور', hint: '••••••••', obscureText: true, onChanged: controller.setPassword),
          const SizedBox(height: 14),
          ClientTextField(label: 'تأكيد كلمة المرور', hint: '••••••••', obscureText: true, onChanged: controller.setConfirmPassword),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          ClientPrimaryButton(label: 'إنشاء الحساب', isLoading: s.isSubmitting, onPressed: controller.doSignup),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لديك حساب؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
              InkWell(
                onTap: () => controller.goTo(ClientScreen.login),
                child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
