import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/client_primary_button.dart';
import '../../core/context_ext.dart';

/// Screen 38 — Voice confirm parsed intent.
class VoiceConfirmScreen extends ConsumerWidget {
  const VoiceConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final transcript = ref.watch(clientFlowControllerProvider.select((s) => s.voiceTranscript));
    final display = transcript.isEmpty ? 'اطلب لي تكسي من موقعي الحالي إلى المطار' : transcript;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        children: [
          const Column(
            children: [
              Text('🤖', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text('هل فهمنا طلبك بشكل صحيح؟', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5), borderRadius: BorderRadius.circular(14)),
            child: Text('"$display"', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF166534))),
          ),
          const Spacer(),
          ClientPrimaryButton(
            label: 'نعم صحيح، تابع',
            onPressed: () => controller.goTo(ClientScreen.rideConfirm, patch: (s) => s.copyWith(flowType: ClientFlowType.taxi, rideDest: 'مطار نواكشوط أم التونسي الدولي')),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.goTo(ClientScreen.home),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.all(16)),
              child: const Text('تعديل يدوي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1C1917))),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => controller.goTo(ClientScreen.voiceRecord, patch: (s) => s.copyWith(voiceStage: VoiceStage.idle)),
            child: const Text('أعد التسجيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF78716C))),
          ),
        ],
      ),
    );
  }
}
