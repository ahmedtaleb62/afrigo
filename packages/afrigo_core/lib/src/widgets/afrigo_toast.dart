import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_typography.dart';

/// Toast from section 0.4 — a dark floating SnackBar with a check mark,
/// auto-dismissing after 2.5s (matches the `showToast` sample behavior).
void showAfrigoToast(
  BuildContext context,
  String message, {
  AfrigoLocale locale = AfrigoLocale.ar,
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2500),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: isError ? AfrigoColors.error : AfrigoColors.green300,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AfrigoTypography.body(locale, color: AfrigoColors.neutral0)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
}
