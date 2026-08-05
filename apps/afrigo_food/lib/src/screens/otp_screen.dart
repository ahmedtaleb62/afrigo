import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_primary_button.dart';

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
        final controller = ref.read(foodFlowControllerProvider.notifier);
        return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [BackCircleButton(onTap: controller.back)]),
              const SizedBox(height: 14),
              const Text('تأكيد الرمز', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(height: 8),
              const Text('أدخل الرمز المرسل إلى بريدك الإلكتروني', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6, color: Color(0xFF78716C))),
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
                          fillColor: const Color(0xFFF5F5F4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              FoodPrimaryButton(label: 'تأكيد', onPressed: controller.confirmOtp),
            ],
          ),
        );
      },
    );
  }
}
