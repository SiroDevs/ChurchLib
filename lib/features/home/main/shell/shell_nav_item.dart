import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../../core/theme/theme_fonts.dart';

class ShellNavItem extends StatelessWidget {
  const ShellNavItem(
    this.icon,
    this.label, {
    super.key,
    this.onPressed,
    this.isSelected = false,
    this.indent = 0,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;
  final double indent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isSelected ? scheme.primary : scheme.onSurface;
    return Material(
      color: isSelected
          ? scheme.primary.withValues(alpha: .14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Row(
        children: [
          SizedBox(width: 12 + indent),
          Icon(icon, size: 22, color: fg),
          const SizedBox(width: 18),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.buttonTextStyle.copyWith(
              color: fg,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          )
              .expanded(),
          if (trailing != null) trailing!,
          if (trailing != null) const SizedBox(width: 8),
        ],
      )
            .height(46),
      ),
    )
        .padding(horizontal: 8, vertical: 2);
  }
}