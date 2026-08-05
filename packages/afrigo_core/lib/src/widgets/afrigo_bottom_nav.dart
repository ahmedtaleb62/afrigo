import 'package:flutter/material.dart';

import '../theme/afrigo_colors.dart';
import '../theme/afrigo_typography.dart';

class AfrigoNavItem {
  const AfrigoNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom navigation bar from section 0.4. Each of the 4 apps supplies its
/// own [items] (e.g. Client: الرئيسية/الطلبات/المحفظة/الحساب) since the
/// destinations differ per app, but the visual spec is shared.
class AfrigoBottomNav extends StatelessWidget {
  const AfrigoBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.locale = AfrigoLocale.ar,
  });

  final List<AfrigoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AfrigoLocale locale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AfrigoColors.neutral0,
        border: Border(top: BorderSide(color: AfrigoColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  item: items[i],
                  selected: i == currentIndex,
                  locale: locale,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.locale,
    required this.onTap,
  });

  final AfrigoNavItem item;
  final bool selected;
  final AfrigoLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AfrigoColors.green600 : AfrigoColors.neutral400;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AfrigoTypography.caption(locale, color: color)
                .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
