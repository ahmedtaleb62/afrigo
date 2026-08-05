import 'package:flutter/material.dart';

/// The rotating ring spinner used on loading screens.
class SpinningRing extends StatefulWidget {
  const SpinningRing({super.key, this.size = 64, this.trackColor = const Color(0xFFE1E5DF), this.activeColor = const Color(0xFF2AA35C)});

  final double size;
  final Color trackColor;
  final Color activeColor;

  @override
  State<SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<SpinningRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.trackColor, width: 4)),
        child: CustomPaint(painter: _ArcPainter(widget.activeColor)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Offset.zero & size, -1.4, 1.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
