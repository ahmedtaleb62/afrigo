import 'package:flutter/widgets.dart';

/// Color tokens for the Afrigo design system (v2.0).
///
/// Values are copied 1:1 from `Afrigo Design System.dc.html` (section 1)
/// so the Flutter apps and the React admin panel render identical colors.
abstract final class AfrigoColors {
  // ---------------------------------------------------------------------
  // Primary / Green — أخضر أفريغو
  // ---------------------------------------------------------------------
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green200 = Color(0xFFBBF7D0);
  static const green300 = Color(0xFF86EFAC);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);

  /// Brand primary ★ — used for primary buttons, links, active states.
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const green800 = Color(0xFF166534);
  static const green900 = Color(0xFF14532D);

  // ---------------------------------------------------------------------
  // Secondary / Yellow — أصفر أفريغو
  // ---------------------------------------------------------------------
  static const yellow50 = Color(0xFFFEFCE8);
  static const yellow100 = Color(0xFFFEF9C3);
  static const yellow200 = Color(0xFFFEF08A);
  static const yellow300 = Color(0xFFFDE047);

  /// Brand secondary ★ — used for accents on dark/green surfaces.
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const yellow600 = Color(0xFFCA8A04);
  static const yellow700 = Color(0xFFA16207);
  static const yellow800 = Color(0xFF854D0E);
  static const yellow900 = Color(0xFF713F12);

  // ---------------------------------------------------------------------
  // Neutral / Stone — أبيض ورمادي محايد
  // ---------------------------------------------------------------------
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFFAFAF9);
  static const neutral100 = Color(0xFFF5F5F4);
  static const neutral200 = Color(0xFFE7E5E4);
  static const neutral300 = Color(0xFFD6D3D1);
  static const neutral400 = Color(0xFFA8A29E);
  static const neutral500 = Color(0xFF78716C);
  static const neutral600 = Color(0xFF57534E);
  static const neutral700 = Color(0xFF44403C);
  static const neutral800 = Color(0xFF292524);
  static const neutral900 = Color(0xFF1C1917);

  // ---------------------------------------------------------------------
  // Semantic — ألوان دلالية
  // ---------------------------------------------------------------------
  /// نجاح / موثّق
  static const success = Color(0xFF16A34A);

  /// تحذير / قيد المراجعة
  static const warning = Color(0xFFF59E0B);

  /// خطأ / مرفوض
  static const error = Color(0xFFDC2626);
  static const errorSurface = Color(0xFFFEF2F2);
  static const errorSurfaceStrong = Color(0xFFFEE2E2);
  static const errorStrong = Color(0xFF991B1B);

  /// معلومة
  static const info = Color(0xFF2563EB);

  // ---------------------------------------------------------------------
  // Status badge pairs (background, foreground) — section 3
  // ---------------------------------------------------------------------
  static const badgePendingBg = yellow100;
  static const badgePendingFg = yellow800;
  static const badgeVerifiedBg = green100;
  static const badgeVerifiedFg = green800;
  static const badgeRejectedBg = errorSurfaceStrong;
  static const badgeRejectedFg = errorStrong;
  static const badgeLowBalanceBg = yellow200;
  static const badgeLowBalanceFg = yellow900;
  static const badgeOfflineBg = neutral200;
  static const badgeOfflineFg = neutral600;
}
