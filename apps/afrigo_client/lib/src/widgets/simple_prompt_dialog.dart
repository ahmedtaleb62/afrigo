import 'package:flutter/material.dart';

import '../core/context_ext.dart';

/// Small shared helpers so screens that need a one-field text prompt or a
/// yes/no confirm don't each hand-roll their own `AlertDialog`.
class SimplePromptDialog {
  SimplePromptDialog._();

  static Future<String?> showTextPrompt(
    BuildContext context, {
    required String title,
    String? initialValue,
    String? hint,
    bool obscureText = false,
    String? confirmLabel,
  }) {
    final l10n = context.l10n;
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
        content: TextField(
          controller: controller,
          obscureText: obscureText,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Tajawal'),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontFamily: 'Tajawal')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel, style: const TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(confirmLabel ?? l10n.commonSave, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    bool danger = false,
  }) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel, style: const TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel ?? l10n.commonConfirm, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: danger ? const Color(0xFFDC2626) : null)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showInfo(BuildContext context, {required String title, required String body}) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(body, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, height: 1.8)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonOk, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
