import 'package:flutter/material.dart';

/// Plain text input matching this design doc's own input style (12px
/// radius, `#F8F9F8` fill, 1.5px `#E1E5DF` border).
class FoodTextField extends StatelessWidget {
  const FoodTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.small = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF1A1D16)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFFA3AB9C)),
        filled: true,
        fillColor: const Color(0xFFF8F9F8),
        contentPadding: EdgeInsets.all(small ? 11 : 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(small ? 10 : 12), borderSide: const BorderSide(color: Color(0xFFE1E5DF), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(small ? 10 : 12), borderSide: const BorderSide(color: Color(0xFFE1E5DF), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(small ? 10 : 12), borderSide: const BorderSide(color: Color(0xFFE1E5DF), width: 1.5)),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF454B3E))),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
