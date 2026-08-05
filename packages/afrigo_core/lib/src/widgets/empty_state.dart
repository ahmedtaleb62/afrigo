import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_spacing.dart';
import '../theme/afrigo_typography.dart';
import 'afrigo_button.dart';

/// Empty state from section 0.4 — used whenever a list/query returns zero
/// rows (no rides yet, no dishes, no notifications, `no_driver_found`, ...).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.emoji = '📭',
    this.actionLabel,
    this.onAction,
    this.locale = AfrigoLocale.ar,
  });

  final String title;
  final String message;
  final String emoji;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AfrigoSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AfrigoSpacing.xs),
            Text(
              title,
              style: AfrigoTypography.body(locale, color: AfrigoColors.neutral900)
                  .copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: AfrigoTypography.caption(locale, color: AfrigoColors.neutral500),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AfrigoSpacing.sm + 2),
              AfrigoButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
