import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text scale for the Afrigo design system (section 0.2), mobile sizes.
///
/// Arabic content uses **Tajawal**, French/Latin content uses **Manrope**,
/// matching the two type samples in `Afrigo Design System.dc.html`.
/// Pick the right builder for the active [AfrigoLocale] — do not hardcode
/// one family app-wide, since the client apps must switch per
/// `profiles.language_pref`.
enum AfrigoLocale { ar, fr }

abstract final class AfrigoTypography {
  static TextStyle _base(
    AfrigoLocale locale, {
    required double size,
    required double height,
    required FontWeight weight,
    Color? color,
  }) {
    final lineHeight = height / size;
    return switch (locale) {
      AfrigoLocale.ar => GoogleFonts.tajawal(
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: color,
        ),
      AfrigoLocale.fr => GoogleFonts.manrope(
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: color,
        ),
    };
  }

  /// H1 — عنوان رئيسي · 28/34
  static TextStyle h1(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 28,
        height: 34,
        weight: locale == AfrigoLocale.ar ? FontWeight.w900 : FontWeight.w800,
        color: color,
      );

  /// H2 — عنوان فرعي · 22/28
  static TextStyle h2(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 22,
        height: 28,
        weight: FontWeight.w700,
        color: color,
      );

  /// H3 — عنوان صغير · 18/24
  static TextStyle h3(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 18,
        height: 24,
        weight: FontWeight.w700,
        color: color,
      );

  /// Body Large — نص أساسي كبير · 16/24
  static TextStyle bodyLarge(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 16,
        height: 24,
        weight: locale == AfrigoLocale.ar ? FontWeight.w400 : FontWeight.w500,
        color: color,
      );

  /// Body — نص أساسي · 14/20
  static TextStyle body(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 14,
        height: 20,
        weight: FontWeight.w400,
        color: color,
      );

  /// Caption — نص توضيحي صغير · 12/16
  static TextStyle caption(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 12,
        height: 16,
        weight: FontWeight.w400,
        color: color,
      );

  /// Button label · 15/1 · weight 700 (matches the `.4` component samples).
  static TextStyle button(AfrigoLocale locale, {Color? color}) => _base(
        locale,
        size: 15,
        height: 15,
        weight: FontWeight.w700,
        color: color,
      );

  static TextTheme textTheme(AfrigoLocale locale, {required Color onSurface}) {
    return TextTheme(
      displaySmall: h1(locale, color: onSurface),
      headlineMedium: h2(locale, color: onSurface),
      headlineSmall: h3(locale, color: onSurface),
      bodyLarge: bodyLarge(locale, color: onSurface),
      bodyMedium: body(locale, color: onSurface),
      bodySmall: caption(locale, color: onSurface),
      labelLarge: button(locale, color: onSurface),
    );
  }
}
