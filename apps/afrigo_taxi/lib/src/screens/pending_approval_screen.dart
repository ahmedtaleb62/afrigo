import 'package:flutter/material.dart';

import '../core/context_ext.dart';

/// Screen 49 — Pending approval.
///
/// Watches the driver's `vehicles` row live via Realtime
/// (`watchVehicleStatus`, started right after `submitVehicleDocs`) and
/// auto-navigates to Home/Rejected the moment an admin actually reviews it.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 52)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(999)),
            child: Text(l10n.badgePending, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFA16207))),
          ),
          Text(l10n.taxiPendingTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(l10n.taxiPendingDesc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.7, color: Color(0xFF78716C))),
        ],
      ),
    );
  }
}
