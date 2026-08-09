import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/widgets.dart';

/// The design's screens hardcode a top offset (54/60px) as a stand-in for
/// the status bar (see app_root.dart's doc comment). That guess is wrong on
/// devices whose real status bar/cutout is taller, so content renders
/// underneath it. `topGap` returns the real OS inset for this device plus
/// the original design's breathing room, so screens stay correct on any
/// phone instead of assuming a fixed status bar height.
extension SafeTopGap on BuildContext {
  double topGap(double extra) => MediaQuery.of(this).padding.top + extra;
}

/// Shorthand for `AfrigoLocalizations.of(context)` — every screen needs
/// this once real ar/fr translation is wired in.
extension L10nX on BuildContext {
  AfrigoLocalizations get l10n => AfrigoLocalizations.of(this);
}
