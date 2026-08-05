import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_spacing.dart';
import '../theme/afrigo_typography.dart';

/// Bottom-sheet confirm dialog from section 0.4 (e.g. "تأكيد إلغاء الرحلة").
/// Returns `true` if the user tapped [confirmLabel], `false`/`null` otherwise.
Future<bool?> showAfrigoConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  AfrigoLocale locale = AfrigoLocale.ar,
  bool destructive = true,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AfrigoSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: AfrigoSpacing.lg),
              decoration: BoxDecoration(
                color: AfrigoColors.neutral200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            title,
            style: AfrigoTypography.h3(locale, color: AfrigoColors.neutral900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AfrigoTypography.body(locale, color: AfrigoColors.neutral500),
          ),
          const SizedBox(height: AfrigoSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: AfrigoColors.neutral100,
                    foregroundColor: AfrigoColors.neutral900,
                  ),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: AfrigoSpacing.xs + 2),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        destructive ? AfrigoColors.error : AfrigoColors.green500,
                  ),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
