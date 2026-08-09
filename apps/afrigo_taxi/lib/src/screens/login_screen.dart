import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../state/taxi_screen.dart';
import '../widgets/taxi_primary_button.dart';
import '../widgets/taxi_text_field.dart';

/// Screen 46 — Driver login. Marketing hero (logo + tagline on the brand
/// gradient) up top, real form fields in a white sheet at the bottom —
/// was a plain form starting right under the status bar before.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);

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
                    const AfrigoLogo(app: AfrigoApp.taxi, size: 72),
                    const SizedBox(height: 18),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
                        children: [TextSpan(text: 'afrigo '), TextSpan(text: 'taxi', style: TextStyle(color: Color(0xE6FFFFFF)))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'انضم لآلاف السائقين، اربح أكثر واعمل بحرية',
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
                  const Text('تسجيل دخول السائق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
                  const SizedBox(height: 6),
                  const Text('أهلًا بعودتك إلى Afrigo Taxi', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
                  const SizedBox(height: 26),
                  TaxiTextField(
                    label: 'رقم الهاتف',
                    hint: '46 12 34 56',
                    keyboardType: TextInputType.phone,
                    onChanged: controller.setPhone,
                  ),
                  const SizedBox(height: 14),
                  TaxiTextField(label: 'كلمة المرور', hint: '••••••••', obscureText: true, onChanged: controller.setPassword),
                  if (s.authError != null) ...[
                    const SizedBox(height: 10),
                    Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
                  ],
                  const SizedBox(height: 24),
                  TaxiPrimaryButton(label: 'دخول', isLoading: s.isSubmitting, onPressed: controller.doLogin),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('سائق جديد؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
                      InkWell(
                        onTap: () => controller.goTo(TaxiScreen.signup),
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
