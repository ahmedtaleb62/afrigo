import 'package:flutter/material.dart';

/// The "›" circle back button used throughout the design (36x36).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, required this.onTap, this.onDark = false});

  final VoidCallback onTap;

  /// True over the dark green header (screen: Wallet) — uses a translucent
  /// white circle instead of the plain `#F0F2EF` one.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFF0F2EF),
        ),
        child: Text('›', style: TextStyle(fontSize: 16, color: onDark ? Colors.white : Colors.black)),
      ),
    );
  }
}
