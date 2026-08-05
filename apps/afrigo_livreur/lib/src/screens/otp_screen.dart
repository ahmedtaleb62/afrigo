import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/livreur_primary_button.dart';

/// Screen — OTP confirmation.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.read(livreurFlowControllerProvider.notifier);
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تأكيد الرمز', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(height: 8),
              const Text('أدخل الرمز المرسل إلى بريدك الإلكتروني', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6, color: Color(0xFF7C8574))),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 52,
                      height: 60,
                      child: TextField(
                        controller: _controllers[i],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF8F9F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE1E5DF), width: 1.5)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE1E5DF), width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2AA35C), width: 1.5)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              LivreurPrimaryButton(label: 'تأكيد', onPressed: controller.confirmOtp),
            ],
          ),
        );
      },
    );
  }
}
