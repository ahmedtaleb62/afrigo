import 'package:flutter/material.dart';

/// The "→" back button used throughout the design (34x34, matching the
/// design's `.backbtn`: 10px radius, 1px `#E7E5E4` border, white fill).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, required this.onTap, this.onDark = false});

  final VoidCallback onTap;

  /// True over a colored header — uses a translucent white tile instead of
  /// the plain white/border one.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: onDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
          border: onDark ? null : Border.all(color: const Color(0xFFE7E5E4)),
        ),
        child: Text('→', style: TextStyle(fontSize: 16, color: onDark ? Colors.white : const Color(0xFF1C1917))),
      ),
    );
  }
}
