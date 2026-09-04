import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';

/// Screen 45 — Splash.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        color: const Color(0xFF16A34A),
        child: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AfrigoLogo(app: AfrigoApp.taxi, size: 72),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
                        children: [TextSpan(text: 'afrigo '), TextSpan(text: 'taxi', style: TextStyle(color: Color(0xE6FFFFFF)))],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: OutlinedButton(
                    onPressed: () => ref.read(taxiFlowControllerProvider.notifier).continueFromSplash(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0x80FFFFFF), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('${context.l10n.commonContinue} ›', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
