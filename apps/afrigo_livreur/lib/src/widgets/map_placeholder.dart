import 'package:flutter/material.dart';

/// The grid-pattern gradient "map" background used on pickup/dropoff/trip
/// screens. Real `google_maps_flutter` integration needs a Maps API key
/// (`.env.example` has the slot) — this placeholder matches the design
/// pixel-for-pixel until that's wired in.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, this.height, this.borderRadius, this.child});

  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD8F3E1), Color(0xFFEFF1EE)]),
          ),
          child: CustomPaint(painter: _GridPainter()),
        ),
        ?child,
      ],
    );

    return SizedBox(
      height: height,
      child: borderRadius != null ? ClipRRect(borderRadius: borderRadius!, child: content) : content,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7CDC3).withValues(alpha: 0.4)
      ..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The pulsing green dot marker centered on [MapPlaceholder].
class MapCenterPin extends StatelessWidget {
  const MapCenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2AA35C),
          boxShadow: [BoxShadow(color: const Color(0xFF2AA35C).withValues(alpha: 0.25), blurRadius: 0, spreadRadius: 8)],
        ),
      ),
    );
  }
}
