import 'package:flutter/material.dart';

/// Plain text input matching the imported design's `.field` spec (10px
/// radius, 1.5px `#D6D3D1` border, no fill — unlike the old placeholder
/// style this replaced, the design never fills text fields with a gray
/// background).
class LivreurTextField extends StatelessWidget {
  const LivreurTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFD6D3D1), width: 1.5));
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFF1C1917)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Color(0xFFA8A29E)),
        contentPadding: const EdgeInsets.all(13),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
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
