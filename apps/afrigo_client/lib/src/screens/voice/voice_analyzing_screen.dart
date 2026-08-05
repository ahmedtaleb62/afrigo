import 'package:flutter/material.dart';

import '../../widgets/spinning_ring.dart';

/// Screen 37 — Voice analyzing (AI parsing intent).
class VoiceAnalyzingScreen extends StatelessWidget {
  const VoiceAnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🤖', style: TextStyle(fontSize: 48)),
          SizedBox(height: 18),
          SpinningRing(size: 64, trackColor: Color(0xFFE7E5E4), activeColor: Color(0xFF16A34A)),
          SizedBox(height: 18),
          Text('جارٍ تحليل طلبك...', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 8),
          Text('يفهم الذكاء الاصطناعي طلبك الصوتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))),
        ],
      ),
    );
  }
}
