import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../core/context_ext.dart';

/// Screen 36 — Voice record.
///
/// Note: this records UI state only for now — actual microphone capture
/// (via `record`), upload to the `voice-recordings` Storage bucket, and
/// transcription (`voice-order-transcribe` Edge Function) all belong to
/// Section 2, not built yet.
class VoiceRecordScreen extends ConsumerWidget {
  const VoiceRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final recording = ref.watch(clientFlowControllerProvider.select((s) => s.voiceStage == VoiceStage.recording));

    final bars = recording ? [18.0, 10.0, 22.0, 14.0, 20.0] : [8.0, 8.0, 8.0, 8.0, 8.0];

    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [Color(0xFF14532D), Color(0xFF166534)])),
      child: Stack(
        children: [
          Positioned(top: context.topGap(12), right: 20, child: BackCircleButton(onTap: controller.back)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(recording ? 'استمع... تحدّث الآن' : 'اضغط للتحدث', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 20),
                InkWell(
                  onTap: controller.toggleRecording,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 110,
                    height: 110,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: recording ? const Color(0xFFDC2626) : const Color(0xFFFACC15),
                      boxShadow: [BoxShadow(color: const Color(0xFFFACC15).withValues(alpha: 0.15), blurRadius: 0, spreadRadius: 12)],
                    ),
                    child: const Text('🎤', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bars
                        .map((h) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 4,
                              height: h,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(2)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  recording ? 'اضغط مجددًا لإيقاف التسجيل' : 'مثال: "اطلب لي تكسي إلى المطار"',
                  style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFBBF7D0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
