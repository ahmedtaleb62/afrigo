import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_spacing.dart';
import '../theme/afrigo_typography.dart';

/// The 5 statuses that recur across `vehicles`, `restaurants`, `wallets`
/// and order tables — kept as one enum so every screen renders identical
/// badge colors for the same underlying DB status.
enum AfrigoStatus { pending, verified, rejected, lowBalance, offline }

/// Status badge/pill from section 0.4 (شارات الحالة).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.locale = AfrigoLocale.ar,
  });

  final AfrigoStatus status;
  final String label;
  final AfrigoLocale locale;

  (Color bg, Color fg) get _colors => switch (status) {
        AfrigoStatus.pending => (AfrigoColors.badgePendingBg, AfrigoColors.badgePendingFg),
        AfrigoStatus.verified => (AfrigoColors.badgeVerifiedBg, AfrigoColors.badgeVerifiedFg),
        AfrigoStatus.rejected => (AfrigoColors.badgeRejectedBg, AfrigoColors.badgeRejectedFg),
        AfrigoStatus.lowBalance => (AfrigoColors.badgeLowBalanceBg, AfrigoColors.badgeLowBalanceFg),
        AfrigoStatus.offline => (AfrigoColors.badgeOfflineBg, AfrigoColors.badgeOfflineFg),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AfrigoSpacing.sm + AfrigoSpacing.xxs,
        vertical: 6,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: AfrigoTypography.caption(locale, color: fg).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
