import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/spinning_ring.dart';

/// Screen 15 — Searching for a taxi driver / delivery courier.
class SearchingScreen extends ConsumerWidget {
  const SearchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final flowType = ref.watch(clientFlowControllerProvider.select((s) => s.flowType));
    final isTaxi = flowType == ClientFlowType.taxi;

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
              Text(
                isTaxi ? 'جارٍ البحث عن سائق قريب...' : 'جارٍ البحث عن عامل توصيل...',
                style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                isTaxi ? 'قد يستغرق الأمر بضع ثوانٍ' : 'سنعلمك فور القبول',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFBBF7D0)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.cancelSearch,
                style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.12), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
                child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
