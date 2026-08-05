import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_typography.dart';

/// Checkbox + trailing label row (section 0.4 "Checkbox / Radio").
class AfrigoCheckboxRow extends StatelessWidget {
  const AfrigoCheckboxRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.locale = AfrigoLocale.ar,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
          const SizedBox(width: 4),
          Text(label, style: AfrigoTypography.body(locale, color: AfrigoColors.neutral900)),
        ],
      ),
    );
  }
}

/// Radio + trailing label row, for a group of `T` values.
class AfrigoRadioRow<T> extends StatelessWidget {
  const AfrigoRadioRow({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.locale = AfrigoLocale.ar,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<T>(
            groupValue: groupValue,
            onChanged: (v) => onChanged(v as T),
            child: Radio<T>(value: value),
          ),
          const SizedBox(width: 4),
          Text(label, style: AfrigoTypography.body(locale, color: AfrigoColors.neutral900)),
        ],
      ),
    );
  }
}

/// Online/offline switch with label underneath (section 0.4 "Switch").
/// Used for `toggle-online-status` in Taxi/Food/Livreur (شاشات 52/66/77).
class AfrigoStatusSwitch extends StatelessWidget {
  const AfrigoStatusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onLabel,
    required this.offLabel,
    this.locale = AfrigoLocale.ar,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(
          value ? onLabel : offLabel,
          style: AfrigoTypography.body(
            locale,
            color: value ? AfrigoColors.green700 : AfrigoColors.neutral500,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
