import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/spinning_ring.dart';
import '../../core/context_ext.dart';

/// Screen 27 — Waiting for restaurant to accept.
class FoodWaitingScreen extends ConsumerWidget {
  const FoodWaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [Color(0xFF14532D), Color(0xFF166534)]),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinningRing(),
              const SizedBox(height: 20),
              Text(l10n.clientFoodWaitingTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 12),
              Text(l10n.clientFoodWaitingSubtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFBBF7D0))),
              const SizedBox(height: 28),
              TextButton(
                onPressed: controller.cancelFoodOrder,
                style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.12), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                child: Text(l10n.clientFoodCancelOrderButton, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
