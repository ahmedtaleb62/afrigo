import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_primary_button.dart';
import '../core/context_ext.dart';

/// Screen 3 — Onboarding (3 steps).
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final step = ref.watch(clientFlowControllerProvider.select((s) => s.onboardStep));
    final ob = ClientFlowController.onboardSteps[step];

    Widget dot(int i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: i == step ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == step ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4),
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, context.topGap(36), 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.goTo(ClientScreen.login),
                child: const Text('تخطي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF78716C))),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ob.emoji, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(ob.title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    ob.desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, height: 1.7, color: Color(0xFF78716C)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, dot)),
          ),
          ClientPrimaryButton(label: step == 2 ? 'ابدأ الآن' : 'التالي', onPressed: controller.onboardNext),
        ],
      ),
    );
  }
}
