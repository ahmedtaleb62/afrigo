import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/map_placeholder.dart';

/// Screen — Navigate to dropoff (leg 2 of 2).
class NavigateToDropoffScreen extends ConsumerWidget {
  const NavigateToDropoffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final delivery = ref.watch(livreurFlowControllerProvider.select((s) => s.activeDelivery));
    final dropoff = delivery?.dropoffLabel ?? '...';
    final recipientName = delivery?.recipientName ?? 'الزبون';

    return Column(
      children: [
        Expanded(
          child: MapPlaceholder(
            child: Stack(
              children: [
                Positioned(
                  top: 54,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF14532D), borderRadius: BorderRadius.circular(10)),
                    child: Text('في الطريق للتسليم: $dropoff', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                  ),
                ),
                const Center(child: Text('🏍️', style: TextStyle(fontSize: 24))),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(width: 48, height: 48, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('👩', style: TextStyle(fontSize: 20))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipientName, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                          Text(delivery?.recipientPhone ?? 'المستلم', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                        ],
                      ),
                    ),
                    Container(width: 40, height: 40, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('📞', style: TextStyle(fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.markDelivered,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('تم التسليم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
