import 'package:flutter/material.dart';

import '../../widgets/spinning_ring.dart';

/// Screen 27 — Waiting for restaurant to accept.
class FoodWaitingScreen extends StatelessWidget {
  const FoodWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [Color(0xFF14532D), Color(0xFF166534)]),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinningRing(),
              SizedBox(height: 20),
              Text('بانتظار قبول المطعم للطلب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
              SizedBox(height: 12),
              Text('سيتم إعلامك فور رد المطعم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFBBF7D0))),
            ],
          ),
        ),
      ),
    );
  }
}
