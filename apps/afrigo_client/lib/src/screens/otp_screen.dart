import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/client_primary_button.dart';
import '../core/context_ext.dart';

/// Screen 6 — OTP confirmation. 6 digits to match Supabase Auth's
/// `sms_otp_length` — the real code Chinguisoft texts, verified for real by
/// `confirmOtp()`.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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

  Future<void> _resend() async {
    if (_countdown > 0) return;
    await ref.read(clientFlowControllerProvider.notifier).resendOtp();
    _startCountdown();
  }

  // A single field's `onChanged` only fires while it still has a character
  // to remove — backspacing an already-empty box fires nothing at all, so
  // without this the user had to tap back into the previous box by hand
  // every time. Listening for the raw backspace key instead lets one
  // continuous stream of backspace presses walk back through every box.
  KeyEventResult _handleBackspace(int i, KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[i].text.isNotEmpty) return KeyEventResult.ignored;
    if (i == 0) return KeyEventResult.ignored;
    _controllers[i - 1].clear();
    ref.read(clientFlowControllerProvider.notifier).setOtpDigit(i - 1, '');
    _focusNodes[i - 1].requestFocus();
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackCircleButton(onTap: controller.back),
          const SizedBox(height: 20),
          Text(l10n.commonOtpTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 8),
          Text(l10n.commonOtpDesc, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6, color: Color(0xFF78716C))),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 44,
                  height: 56,
                  child: Focus(
                    onKeyEvent: (node, event) => _handleBackspace(i, event),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (v) {
                        controller.setOtpDigit(i, v);
                        if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                      },
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFAFAF9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                      ),
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
              onTap: _countdown > 0 ? null : _resend,
              child: Text(
                _countdown > 0 ? l10n.commonResendIn(_countdown) : l10n.commonResend,
                style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: _countdown > 0 ? const Color(0xFFA8A29E) : const Color(0xFF166534)),
              ),
            ),
          ),
          const Spacer(),
          ClientPrimaryButton(label: l10n.commonConfirm, isLoading: s.isSubmitting, onPressed: controller.confirmOtp),
        ],
      ),
    );
  }
}
