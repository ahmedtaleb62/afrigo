import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../widgets/taxi_primary_button.dart';

/// Screen — OTP confirmation (driver signup). 6 digits to match Supabase
/// Auth's `sms_otp_length` — the real code Chinguisoft texts, verified for
/// real by `confirmOtp()`.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  Timer? _timer;
  int _countdown = 45;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
    });
  }

  Future<void> _resend(TaxiFlowController controller) async {
    if (_countdown > 0) return;
    await controller.resendOtp();
    _startCountdown();
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
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.read(taxiFlowControllerProvider.notifier);
        final s = ref.watch(taxiFlowControllerProvider);
        return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تأكيد الرمز', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(height: 8),
              const Text('أدخل الرمز المكوّن من 6 أرقام المرسل إلى رقم هاتفك', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6, color: Color(0xFF78716C))),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 44,
                      height: 56,
                      child: TextField(
                        controller: _controllers[i],
                        onChanged: (v) {
                          controller.setOtpDigit(i, v);
                          if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                        },
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFFAFAF9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (s.authError != null) ...[
                const SizedBox(height: 14),
                Center(child: Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626)))),
              ],
              const SizedBox(height: 24),
              Center(
                child: InkWell(
                  onTap: _countdown > 0 ? null : () => _resend(controller),
                  child: Text(
                    _countdown > 0 ? 'إعادة الإرسال خلال $_countdown ثانية' : 'إعادة الإرسال',
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: _countdown > 0 ? const Color(0xFFA8A29E) : const Color(0xFF166534)),
                  ),
                ),
              ),
              const Spacer(),
              TaxiPrimaryButton(label: 'تأكيد', isLoading: s.isSubmitting, onPressed: controller.confirmOtp),
            ],
          ),
        );
      },
    );
  }
}
