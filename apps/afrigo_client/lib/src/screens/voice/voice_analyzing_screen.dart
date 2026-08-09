import 'package:flutter/material.dart';

import '../../widgets/spinning_ring.dart';
import '../../core/context_ext.dart';

/// Screen 37 — Voice analyzing (AI parsing intent).
class VoiceAnalyzingScreen extends StatelessWidget {
  const VoiceAnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 18),
          const SpinningRing(size: 64, trackColor: Color(0xFFE7E5E4), activeColor: Color(0xFF16A34A)),
          const SizedBox(height: 18),
          Text(l10n.clientVoiceAnalyzingTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 8),
          Text(l10n.clientVoiceAnalyzingDesc, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
        ],
      ),
    );
  }
}
