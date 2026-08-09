import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/client_primary_button.dart';
import '../widgets/client_text_field.dart';

/// Screen 5 — Signup. Same marketing-hero-over-form-sheet layout as the
/// login screen, just a shorter hero to leave room for 4 fields.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment(-0.4, -1), end: Alignment(0.4, 1), colors: [Color(0xFF14532D), Color(0xFF166534)])),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [BackCircleButton(onTap: controller.back, onLight: true)]),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AfrigoLogo(app: AfrigoApp.client, size: 56),
                    const SizedBox(height: 14),
                    const Text('انضم إلى Afrigo', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'أنشئ حسابك وابدأ الطلب خلال دقائق',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFBBF7D0), height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: ListView(
                  children: [
                  const Text('إنشاء حساب جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20)),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 22),
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
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
