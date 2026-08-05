import 'package:flutter/material.dart';

/// The rounded-square `.backbtn` used throughout the design (34x34, 10px
/// radius, `#E7E5E4` border) — shows a plain arrow that flips direction
/// under RTL, matching the design's `backArrow` (`→` for RTL, `←` for LTR).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, required this.onTap, this.onLight = false});

  final VoidCallback onTap;

  /// True when placed over a photo/map/gradient header — adds a soft shadow
  /// so the button stays legible against a busy background.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E5E4)),
          boxShadow: onLight
              ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))]
              : null,
        ),
        child: Text(isRtl ? '→' : '←', style: const TextStyle(fontSize: 16, color: Color(0xFF1C1917))),
      ),
    );
  }
}
