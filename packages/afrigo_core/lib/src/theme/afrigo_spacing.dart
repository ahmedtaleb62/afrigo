/// Spacing scale (4px base grid) used across all Afrigo apps.
abstract final class AfrigoSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Corner-radius scale, matching the values used across
/// `Afrigo Design System.dc.html` (buttons: 12, inputs: 10, cards: 14-18,
/// badges/pills: 999).
abstract final class AfrigoRadius {
  static const input = 10.0;
  static const button = 12.0;
  static const card = 14.0;
  static const cardLarge = 18.0;
  static const bottomSheet = 20.0;
  static const pill = 999.0;
}
