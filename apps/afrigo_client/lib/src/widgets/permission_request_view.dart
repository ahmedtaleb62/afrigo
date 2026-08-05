import 'package:flutter/material.dart';

import 'client_primary_button.dart';

/// Shared layout for screens 8 (Location) and 9 (Notifications) — same
/// structure (emoji, title, desc, primary + skip button), different copy.
class PermissionRequestView extends StatelessWidget {
  const PermissionRequestView({
    super.key,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSkip,
  });

  final String emoji;
  final String title;
  final String desc;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, height: 1.7, color: Color(0xFF78716C)),
          ),
          const Spacer(),
          ClientPrimaryButton(label: primaryLabel, onPressed: onPrimary),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: const Text('ليس الآن', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF78716C))),
          ),
        ],
      ),
    );
  }
}
