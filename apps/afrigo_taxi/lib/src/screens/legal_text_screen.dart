import 'package:flutter/material.dart';

import '../widgets/back_circle_button.dart';

/// Shared layout for the three simple legal/info pages (عن التطبيق، الشروط
/// والأحكام، سياسة الخصوصية) — reads admin-editable content from
/// `platform_settings` (`TaxiFlowState.aboutText`/`termsText`/`privacyText`).
class LegalTextScreen extends StatelessWidget {
  const LegalTextScreen({super.key, required this.title, required this.body, required this.onBack});

  final String title;
  final String body;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: onBack),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                body.isNotEmpty ? body : 'لا يوجد محتوى بعد.',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, height: 1.9, color: Color(0xFF44403C)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
