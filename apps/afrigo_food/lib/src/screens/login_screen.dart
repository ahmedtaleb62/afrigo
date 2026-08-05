import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

/// Screen — Restaurant login.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: ListView(
        children: [
          const Text('تسجيل دخول المطعم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 26)),
          const SizedBox(height: 6),
          const Text('أهلًا بعودتك إلى Afrigo Food', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF7C8574))),
          const SizedBox(height: 28),
          FoodTextField(label: 'البريد الإلكتروني', hint: 'restaurant@afrigo.com', onChanged: controller.setEmail),
          const SizedBox(height: 14),
          FoodTextField(label: 'كلمة المرور', hint: '••••••••', obscureText: true, onChanged: controller.setPassword),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FoodPrimaryButton(label: 'دخول', isLoading: s.isSubmitting, onPressed: controller.doLogin),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('مطعم جديد؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF7C8574))),
              InkWell(
                onTap: () => controller.goTo(FoodScreen.signup),
                child: const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF176F3D))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
