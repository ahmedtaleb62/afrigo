import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/client_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../core/context_ext.dart';

/// Screen 44 — Support & help.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final supportPhone = ref.watch(clientFlowControllerProvider.select((s) => s.supportPhone));

    Widget faq(String q) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: const Color(0xFFFAFAF9), borderRadius: BorderRadius.circular(12)),
          child: Text(q, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
        );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
      child: ListView(
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              Text(l10n.clientSupportTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.clientSupportFaqLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF78716C))),
          const SizedBox(height: 10),
          faq(l10n.clientSupportFaq1),
          faq(l10n.clientSupportFaq2),
          faq(l10n.clientSupportFaq3),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse('https://wa.me/${supportPhone.replaceAll('+', '')}'), mode: LaunchMode.externalApplication),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(l10n.clientSupportWhatsapp, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: supportPhone)),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.all(15)),
              child: Text(l10n.clientSupportCallUs, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1C1917))),
            ),
          ),
        ],
      ),
    );
  }
}
