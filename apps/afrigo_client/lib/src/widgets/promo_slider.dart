import 'dart:async';

import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';

import '../core/context_ext.dart';

class _PromoSlide {
  const _PromoSlide({required this.title, required this.subtitle, required this.icon, required this.gradient, required this.textColor, required this.subColor});
  final String title;
  final String subtitle;
  final String icon;
  final Gradient gradient;
  final Color textColor;
  final Color subColor;
}

const _slideCount = 3;

List<_PromoSlide> _slides(AfrigoLocalizations l10n) => [
      _PromoSlide(
        title: l10n.clientPromoTaxiTitle,
        subtitle: l10n.clientPromoTaxiSubtitle,
        icon: '🚕',
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)]),
        textColor: const Color(0xFF166534),
        subColor: const Color(0xFF15803D),
      ),
      _PromoSlide(
        title: l10n.clientPromoFoodTitle,
        subtitle: l10n.clientPromoFoodSubtitle,
        icon: '🍽️',
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFEF9C3), Color(0xFFFEFCE8)]),
        textColor: const Color(0xFF854D0E),
        subColor: const Color(0xFFA16207),
      ),
      _PromoSlide(
        title: l10n.clientPromoParcelTitle,
        subtitle: l10n.clientPromoParcelSubtitle,
        icon: '📦',
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1C1917), Color(0xFF292524)]),
        textColor: Colors.white,
        subColor: const Color(0xFFD6D3D1),
      ),
    ];

/// Home screen's promotional carousel — replaces the live map that used to
/// sit here (screens 10/11 in the design no longer show one at all).
/// Auto-advances every 3.5s with a cross-fade, matching the source design's
/// own `componentDidMount` timer; tapping a dot jumps straight to that slide.
class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key});

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _slideCount);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides(context.l10n);
    return Container(
      height: 150,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          for (var i = 0; i < slides.length; i++)
            // `Positioned` must be Stack's *direct* child — it was
            // previously returned from inside `_SlideCard.build()`, one
            // level below `AnimatedOpacity`, which isn't a Stack child
            // itself. Flutter can't apply StackParentData through that
            // extra layer, and throws (repeatedly, every rebuild) instead
            // of just laying it out wrong — which froze the whole home
            // screen the moment this widget first mounted.
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: i == _index ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: _SlideCard(slide: slides[i]),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _index = i),
                      borderRadius: BorderRadius.circular(3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: i == _index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _index ? const Color(0xFF16A34A) : Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.slide});
  final _PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: slide.gradient),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(slide.title, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: slide.textColor)),
                const SizedBox(height: 6),
                Text(slide.subtitle, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: slide.subColor)),
              ],
            ),
          ),
          Text(slide.icon, style: const TextStyle(fontSize: 38)),
        ],
      ),
    );
  }
}
