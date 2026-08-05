import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../core/context_ext.dart';

/// Screen 20 — Trip rating.
class TripRatingScreen extends ConsumerStatefulWidget {
  const TripRatingScreen({super.key});

  @override
  ConsumerState<TripRatingScreen> createState() => _TripRatingScreenState();
}

class _TripRatingScreenState extends ConsumerState<TripRatingScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final avatar = s.flowType == ClientFlowType.taxi ? '🧔' : '🏍️';
    final name = s.providerName ?? '...';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: Text(avatar, style: const TextStyle(fontSize: 26))),
          const SizedBox(height: 14),
          Text('قيّم $name', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('كيف كانت تجربتك؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = s.ratingStars >= i + 1;
              return InkWell(
                onTap: () => controller.rate(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(filled ? '⭐' : '☆', style: const TextStyle(fontSize: 30)),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Tag('نظيف 🧼'),
              _Tag('مؤدب 🙏'),
              _Tag('سريع ⚡'),
            ],
          ),
          const SizedBox(height: 24),
          ClientTextField(hint: 'أضف تعليقًا (اختياري)', controller: _commentController),
          const Spacer(),
          ClientPrimaryButton(label: 'إرسال', onPressed: () => controller.finishRating(comment: _commentController.text)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: controller.finishRating,
            child: const Text('تخطي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF78716C))),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
