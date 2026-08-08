import 'dart:async';

import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/client_flow_controller.dart';

/// Screen 1 — Splash. A returning, already-logged-in user should never
/// really see this screen — it now only holds for the brief brand-mark
/// pause when there's actually no session yet (first-time visitor, or
/// someone who signed out). With a persisted session it proceeds on the
/// very next frame instead of waiting out the same pause, so it reads as
/// "goes straight into the app" rather than a flash of green every launch.
/// The button stays as a manual skip for anyone who taps before that.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _autoContinue;

  @override
  void initState() {
    super.initState();
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    _autoContinue = Timer(hasSession ? Duration.zero : const Duration(milliseconds: 900), _continue);
  }

  @override
  void dispose() {
    _autoContinue?.cancel();
    super.dispose();
  }

  void _continue() {
    _autoContinue?.cancel();
    if (!mounted) return;
    ref.read(clientFlowControllerProvider.notifier).continueFromSplash();
  }

  @override
  Widget build(BuildContext context) {
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
                  AfrigoLogo(app: AfrigoApp.client, size: 72),
                  SizedBox(height: 18),
                  Text('afrigo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 26, color: Colors.white)),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: OutlinedButton(
                  onPressed: _continue,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x80FFFFFF), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('متابعة ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
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
