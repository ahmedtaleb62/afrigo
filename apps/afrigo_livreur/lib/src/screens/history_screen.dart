import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../state/livreur_screen.dart';
import '../widgets/back_circle_button.dart';

/// Screen 81 — Delivery history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(livreurFlowControllerProvider.notifier);

    Widget delivery(String name, String price, String meta) => Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(price, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF176F3D))),
                ],
              ),
              Text(meta, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF7C8574))),
            ],
          ),
        );

    return Container(
      color: const Color(0xFFF8F9F8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 12),
            child: Row(
              children: [
                BackCircleButton(onTap: () => controller.goTo(LivreurScreen.home)),
                const SizedBox(width: 12),
                const Text('سجل التوصيلات', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                delivery('سارة بن علي', '220 أوقية', 'اليوم 12:40 · 4.1 كم'),
                delivery('كريم شريف', '180 أوقية', 'أمس 17:05 · 3.2 كم'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
