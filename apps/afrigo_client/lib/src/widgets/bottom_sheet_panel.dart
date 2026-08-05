import 'package:flutter/material.dart';

/// The white rounded-top panel that overlaps a [MapPlaceholder] by -20px,
/// used on ride/parcel origin/confirm/tracking screens.
class BottomSheetPanel extends StatelessWidget {
  const BottomSheetPanel({
    super.key,
    required this.child,
    this.scrollable = false,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 20),
  });

  final Widget child;
  final bool scrollable;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: scrollable ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}
