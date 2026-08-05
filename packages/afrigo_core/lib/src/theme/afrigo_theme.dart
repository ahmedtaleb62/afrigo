import 'package:flutter/material.dart';

import 'afrigo_colors.dart';
import 'afrigo_spacing.dart';
import 'afrigo_typography.dart';

export 'afrigo_colors.dart';
export 'afrigo_spacing.dart';
export 'afrigo_typography.dart';

/// Builds the single, shared `ThemeData` used by all four Flutter apps.
///
/// The design system only defines one (light) surface — there is no dark
/// variant in `Afrigo Design System.dc.html` — so [light] is the only
/// factory. `locale` picks the font family (Tajawal for ar, Manrope for fr)
/// per `profiles.language_pref`; it does not affect colors or spacing.
abstract final class AfrigoTheme {
  static ThemeData light({required AfrigoLocale locale}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AfrigoColors.green500,
      brightness: Brightness.light,
      primary: AfrigoColors.green500,
      onPrimary: AfrigoColors.neutral0,
      secondary: AfrigoColors.yellow400,
      onSecondary: AfrigoColors.neutral900,
      error: AfrigoColors.error,
      onError: AfrigoColors.neutral0,
      surface: AfrigoColors.neutral0,
      onSurface: AfrigoColors.neutral900,
    );

    final textTheme = AfrigoTypography.textTheme(
      locale,
      onSurface: AfrigoColors.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AfrigoColors.neutral50,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      dividerColor: AfrigoColors.neutral200,
      appBarTheme: AppBarTheme(
        backgroundColor: AfrigoColors.neutral50,
        foregroundColor: AfrigoColors.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AfrigoTypography.h3(locale, color: AfrigoColors.neutral900),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AfrigoColors.green500,
          foregroundColor: AfrigoColors.neutral0,
          disabledBackgroundColor: AfrigoColors.neutral200,
          disabledForegroundColor: AfrigoColors.neutral400,
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.xl,
            vertical: AfrigoSpacing.sm + AfrigoSpacing.xxs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfrigoRadius.button),
          ),
          textStyle: AfrigoTypography.button(locale),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AfrigoColors.green700,
          side: const BorderSide(color: AfrigoColors.green500, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.xl - AfrigoSpacing.xxs,
            vertical: AfrigoSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfrigoRadius.button),
          ),
          textStyle: AfrigoTypography.button(locale, color: AfrigoColors.green700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AfrigoColors.green700,
          textStyle: AfrigoTypography.button(locale, color: AfrigoColors.green700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AfrigoColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AfrigoSpacing.md - AfrigoSpacing.xxs,
          vertical: AfrigoSpacing.sm + AfrigoSpacing.xxs,
        ),
        hintStyle: AfrigoTypography.body(locale, color: AfrigoColors.neutral500),
        labelStyle: AfrigoTypography.body(locale, color: AfrigoColors.neutral700)
            .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
        errorStyle: AfrigoTypography.caption(locale, color: AfrigoColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.input),
          borderSide: const BorderSide(color: AfrigoColors.neutral200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.input),
          borderSide: const BorderSide(color: AfrigoColors.neutral200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.input),
          borderSide: const BorderSide(color: AfrigoColors.green500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.input),
          borderSide: const BorderSide(color: AfrigoColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.input),
          borderSide: const BorderSide(color: AfrigoColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AfrigoColors.neutral0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AfrigoColors.green500
              : AfrigoColors.neutral200,
        ),
        thumbColor: const WidgetStatePropertyAll(AfrigoColors.neutral0),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AfrigoColors.green500
              : AfrigoColors.neutral200,
        ),
        checkColor: const WidgetStatePropertyAll(AfrigoColors.neutral0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AfrigoColors.green500
              : AfrigoColors.neutral300,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AfrigoColors.neutral900,
        contentTextStyle: AfrigoTypography.body(locale, color: AfrigoColors.neutral0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AfrigoRadius.button),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AfrigoColors.neutral0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AfrigoRadius.bottomSheet),
          ),
        ),
      ),
    );
  }
}
