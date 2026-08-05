import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/client_primary_button.dart';
import '../core/context_ext.dart';

/// Screen 6 — OTP confirmation.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  Timer? _timer;
  int _countdown = 45;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackCircleButton(onTap: controller.back),
          const SizedBox(height: 20),
          const Text('تأكيد الرمز', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 8),
          const Text('أدخل الرمز المكوّن من 4 أرقام المرسل إلى رقم هاتفك', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6, color: Color(0xFF78716C))),
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
                    onChanged: (v) => controller.setOtpDigit(i, v),
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFFAFAF9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _countdown > 0 ? 'إعادة الإرسال خلال $_countdown ثانية' : 'إعادة الإرسال',
              style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFA8A29E)),
            ),
          ),
          const Spacer(),
          ClientPrimaryButton(label: 'تأكيد', onPressed: controller.confirmOtp),
        ],
      ),
    );
  }
}
