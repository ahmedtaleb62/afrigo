import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Which of the 4 Afrigo apps this mark belongs to (section 1 of the
/// design system — each has its own 72x72 mark on the shared green tile).
enum AfrigoApp { client, taxi, food, livreur }

const _clientSvg = '''
<svg width="72" height="72" viewBox="0 0 56 56" xmlns="http://www.w3.org/2000/svg">
<circle cx="28" cy="28" r="22" fill="none" stroke="#16A34A" stroke-width="5"/>
<circle cx="41" cy="15" r="4" fill="#FACC15"/>
<text x="28" y="36" font-size="22" text-anchor="middle" fill="#16A34A" font-family="Poppins,sans-serif" font-weight="800">A</text>
</svg>
''';

const _taxiSvg = '''
<svg width="72" height="72" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
<rect x="52" y="52" width="408" height="408" rx="104" fill="#1C1917"/>
<g transform="translate(256 268)">
  <path d="M-118 42 L-118 4 Q-118 -14 -100 -22 L-76 -76 Q-66 -98 -40 -98 L40 -98 Q66 -98 76 -76 L100 -22 Q118 -14 118 4 L118 42 Q118 58 102 58 L96 58 Q96 76 78 76 Q60 76 60 58 L-60 58 Q-60 76 -78 76 Q-96 76 -96 58 L-102 58 Q-118 58 -118 42 Z" fill="#fff"/>
  <path d="M-84 -22 L-64 -70 Q-58 -82 -44 -82 L44 -82 Q58 -82 64 -70 L84 -22 Z" fill="#1C1917"/>
  <rect x="-96" y="-8" width="58" height="30" rx="6" fill="#1C1917"/>
  <rect x="38" y="-8" width="58" height="30" rx="6" fill="#1C1917"/>
  <circle cx="-78" cy="58" r="26" fill="#1C1917"/>
  <circle cx="-78" cy="58" r="10" fill="#fff"/>
  <circle cx="78" cy="58" r="26" fill="#1C1917"/>
  <circle cx="78" cy="58" r="10" fill="#fff"/>
  <rect x="-14" y="-118" width="28" height="16" rx="4" fill="#FACC15"/>
</g>
</svg>
''';

const _foodSvg = '''
<svg width="72" height="72" viewBox="0 0 56 56" xmlns="http://www.w3.org/2000/svg">
<circle cx="28" cy="28" r="22" fill="none" stroke="#fff" stroke-width="5"/>
<circle cx="25" cy="28" r="9" fill="none" stroke="#fff" stroke-width="3"/>
<rect x="35" y="18" width="3" height="20" fill="#FACC15"/>
<rect x="40" y="18" width="3" height="9" fill="#FACC15"/>
</svg>
''';

/// Amber/gold (`AfrigoColors.yellow600`) — the design system's own secondary
/// brand color, previously never used as an app-tile identity. Chosen for
/// Livreur specifically because green (client), black (taxi) and blue
/// (food) were already taken; amber keeps it inside the existing palette
/// while staying maximally distinct from its 3 siblings.
const _livreurSvg = '''
<svg width="72" height="72" viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg">
<rect x="2" y="2" width="68" height="68" rx="15" fill="#CA8A04"/>
<circle cx="36" cy="35" r="20" fill="none" stroke="#fff" stroke-width="4.5"/>
<circle cx="26" cy="46" r="7" fill="none" stroke="#fff" stroke-width="3"/>
<circle cx="46" cy="46" r="7" fill="none" stroke="#fff" stroke-width="3"/>
<path d="M26 46 L35 30 L45 46 M31 36 H40" stroke="#fff" stroke-width="3" fill="none" stroke-linecap="round"/>
<circle cx="49" cy="18" r="5" fill="#166534"/>
</svg>
''';

/// Renders the primary (color-on-transparent) mark for [app], pixel-identical
/// to the SVGs in `Afrigo Design System.dc.html` section 1. Use this for
/// splash screens, app bars and the design system's own gallery — app-icon
/// export variants (light/checkerboard/dark) are a packaging concern, not a
/// runtime widget, and are handled by each app's `flutter_launcher_icons`
/// config instead.
class AfrigoLogo extends StatelessWidget {
  const AfrigoLogo({super.key, required this.app, this.size = 72});

  final AfrigoApp app;
  final double size;

  String get _svg => switch (app) {
        AfrigoApp.client => _clientSvg,
        AfrigoApp.taxi => _taxiSvg,
        AfrigoApp.food => _foodSvg,
        AfrigoApp.livreur => _livreurSvg,
      };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: size, height: size);
  }
}
