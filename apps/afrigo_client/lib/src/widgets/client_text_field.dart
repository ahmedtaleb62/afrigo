import 'package:flutter/material.dart';

/// Plain text input matching this design doc's own `.field` style exactly
/// (10px radius, white fill, 1.5px `#D6D3D1` border) — a bit different from
/// `AfrigoTextField` in afrigo_core (label above only), so we match this
/// screen set's literal spec rather than force the shared widget.
class ClientTextField extends StatelessWidget {
  const ClientTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.borderColor = const Color(0xFFD6D3D1),
    this.textAlign = TextAlign.start,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color borderColor;
  final TextAlign textAlign;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: onSubmitted != null ? TextInputAction.search : null,
      textAlign: textAlign,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF1C1917)),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFFA8A29E)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF57534E))),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
