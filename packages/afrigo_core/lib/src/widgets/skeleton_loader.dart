import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';

/// Shimmering placeholder block (section 0.4 "Skeleton Loader").
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1 + 4 * t, 0),
              end: Alignment(4 * t, 0),
              colors: const [
                AfrigoColors.neutral100,
                AfrigoColors.neutral200,
                AfrigoColors.neutral100,
              ],
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AfrigoColors.neutral100,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// A ready-made "list tile" skeleton: avatar + two lines, matching the
/// design system sample exactly.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBox(width: 48, height: 48, borderRadius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 8),
              SkeletonBox(width: 120, height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
