import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_primary_button.dart';
import '../widgets/client_text_field.dart';

/// Screen 4 — Login. Marketing hero (logo + tagline on the brand gradient)
/// up top, real form fields in a white sheet at the bottom — was a plain
/// form starting right under the status bar before.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

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
            Flexible(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AfrigoLogo(app: AfrigoApp.client, size: 72),
                    const SizedBox(height: 18),
                    const Text('afrigo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 26, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'تكسي، طعام، وتوصيل طرود — كل خدماتك في تطبيق واحد',
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
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: ListView(
                  children: [
                  const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
                  const SizedBox(height: 6),
                  const Text('أهلًا بعودتك إلى Afrigo', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
                  const SizedBox(height: 26),
                  ClientTextField(
                    label: 'البريد الإلكتروني أو رقم الهاتف',
                    hint: 'example@afrigo.com',
                    onChanged: controller.setEmail,
                  ),
                  const SizedBox(height: 14),
                  ClientTextField(
                    label: 'كلمة المرور',
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
                      child: const Text('نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClientPrimaryButton(label: 'دخول', isLoading: s.isSubmitting, onPressed: controller.doLogin),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
                      InkWell(
                        onTap: () => controller.goTo(ClientScreen.signup),
                        child: const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF166534))),
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
