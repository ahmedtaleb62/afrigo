import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

/// Screen — Restaurant signup.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: ListView(
        children: [
          const Text('إنشاء حساب مطعم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 24),
          FoodTextField(label: 'اسم صاحب الحساب', hint: 'مثال: كريم عبابسة', onChanged: controller.setFullName),
          const SizedBox(height: 14),
          FoodTextField(label: 'البريد الإلكتروني', onChanged: controller.setEmail),
          const SizedBox(height: 14),
          FoodTextField(label: 'كلمة المرور', obscureText: true, onChanged: controller.setPassword),
          const SizedBox(height: 14),
          FoodTextField(label: 'تأكيد كلمة المرور', obscureText: true, onChanged: controller.setConfirmPassword),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FoodPrimaryButton(label: 'إنشاء الحساب', isLoading: s.isSubmitting, onPressed: controller.doSignup),
        ],
      ),
    );
  }
}
