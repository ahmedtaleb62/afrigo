import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_typography.dart';

/// Input field from section 0.4: label above, optional error text below,
/// optional trailing icon (used for the password visibility toggle).
class AfrigoTextField extends StatelessWidget {
  const AfrigoTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.enabled = true,
    this.locale = AfrigoLocale.ar,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AfrigoTypography.body(locale, color: AfrigoColors.neutral700)
              .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          style: AfrigoTypography.body(locale, color: AfrigoColors.neutral900),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
