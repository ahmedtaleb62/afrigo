import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';

/// Screen 61 — Splash.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [Color(0xFF0F3F23), Color(0xFF176F3D)])),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AfrigoLogo(app: AfrigoApp.food, size: 80),
                const SizedBox(height: 18),
                const Text('Afrigo Food — الشركاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                const SizedBox(height: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF5C518)))),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () => ref.read(foodFlowControllerProvider.notifier).goTo(FoodScreen.login),
                child: const Text('متابعة ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0x8882D6A0))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
