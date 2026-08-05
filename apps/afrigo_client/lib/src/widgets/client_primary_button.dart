import 'package:flutter/material.dart';

/// Full-width primary button matching this design doc's literal spec
/// (14px radius, 16px padding, 700/15px label) — slightly different from
/// `AfrigoButton`'s theme (12px radius), kept local for pixel fidelity.
class ClientPrimaryButton extends StatelessWidget {
  const ClientPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color = const Color(0xFF16A34A),
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}

/// The plain-text "ليس الآن" / "تخطي" style secondary action.
class ClientTextButton extends StatelessWidget {
  const ClientTextButton({super.key, required this.label, required this.onPressed, this.color = const Color(0xFF78716C)});

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: color),
      child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}
