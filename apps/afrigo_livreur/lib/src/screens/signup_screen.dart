import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/livreur_primary_button.dart';
import '../widgets/livreur_text_field.dart';

/// Screen — Livreur signup.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final s = ref.watch(livreurFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: ListView(
        children: [
          const Text('إنشاء حساب عامل توصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 24),
          LivreurTextField(label: 'الاسم الكامل', hint: 'مثال: ياسين شريف', onChanged: controller.setFullName),
          const SizedBox(height: 14),
          LivreurTextField(label: 'رقم الهاتف', hint: '46 12 34 56', keyboardType: TextInputType.phone, onChanged: controller.setPhone),
          const SizedBox(height: 14),
          LivreurTextField(label: 'كلمة المرور', obscureText: true, onChanged: controller.setPassword),
          const SizedBox(height: 14),
          LivreurTextField(label: 'تأكيد كلمة المرور', obscureText: true, onChanged: controller.setConfirmPassword),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          LivreurPrimaryButton(label: 'إنشاء الحساب', isLoading: s.isSubmitting, onPressed: controller.doSignup),
        ],
      ),
    );
  }
}
