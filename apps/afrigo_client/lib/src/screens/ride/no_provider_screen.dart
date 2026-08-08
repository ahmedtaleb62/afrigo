import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';

/// Screen 16 — No provider found.
class NoProviderScreen extends ConsumerWidget {
  const NoProviderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final flowType = ref.watch(clientFlowControllerProvider.select((s) => s.flowType));
    final providerNoun = flowType == ClientFlowType.taxi ? 'سائق' : 'عامل توصيل';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('لم نتمكن من إيجاد $providerNoun متاح', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('قد تكون الكثافة مرتفعة حاليًا في منطقتك، حاول مجددًا خلال لحظات', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  // Not `controller.back` — the screen we arrived from here
                  // is `searching` (pushed by `_armSearchTimeout`'s own
                  // `goTo`), so back() would land on the dead "جاري
                  // البحث..." screen instead of actually leaving the flow.
                  onPressed: () => controller.goTo(ClientScreen.home),
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.all(14)),
                  child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1C1917))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: controller.startSearch,
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.all(14)),
                  child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
