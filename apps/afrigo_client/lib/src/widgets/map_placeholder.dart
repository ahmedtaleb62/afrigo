import 'package:flutter/material.dart';

/// The grid-pattern gradient "map" background used everywhere a screen
/// implies a map (ride/parcel origin-destination-tracking screens). Real
/// `google_maps_flutter` integration needs a Maps API key (`.env.example`
/// has the slot) — this placeholder matches the design pixel-for-pixel
/// until that's wired in.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, this.height, this.child});

  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
              ),
            ),
            child: CustomPaint(painter: _GridPainter()),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6D3D1).withValues(alpha: 0.4)
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
  const MapCenterPin({super.key, this.withStem = false});

  final bool withStem;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF16A34A),
        boxShadow: [BoxShadow(color: const Color(0xFF16A34A).withValues(alpha: 0.25), blurRadius: 0, spreadRadius: 8)],
      ),
    );
    if (!withStem) return Center(child: dot);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [dot, Container(width: 2, height: 20, color: const Color(0xFF16A34A))],
      ),
    );
  }
}
