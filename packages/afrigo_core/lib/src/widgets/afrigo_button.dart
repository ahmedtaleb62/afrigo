import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_spacing.dart';

enum AfrigoButtonVariant { primary, secondary }

/// Button component from section 0.4 of the design system: primary, secondary,
/// disabled (pass `onPressed: null`), and loading (pass `isLoading: true`).
class AfrigoButton extends StatelessWidget {
  const AfrigoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AfrigoButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AfrigoButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final child = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AfrigoButtonVariant.primary
                    ? AfrigoColors.neutral0
                    : AfrigoColors.green700,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AfrigoSpacing.xs),
              ],
              Text(label),
            ],
          );

    final button = variant == AfrigoButtonVariant.primary
        ? ElevatedButton(onPressed: disabled ? null : onPressed, child: child)
        : OutlinedButton(onPressed: disabled ? null : onPressed, child: child);

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
