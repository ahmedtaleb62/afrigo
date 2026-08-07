import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/map_placeholder.dart';

/// Screen 79 — Navigate to pickup (leg 1 of 2).
class NavigateToPickupScreen extends ConsumerWidget {
  const NavigateToPickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final pickup = ref.watch(livreurFlowControllerProvider.select((s) => s.activeDelivery?.pickupLabel)) ?? '...';

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
                    child: Text('في الطريق لاستلام الطرد من: $pickup', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.markPickedUp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('تم الاستلام', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
