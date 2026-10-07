// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/theme_fonts.dart';

class ShellNavItem extends StatelessWidget {
  const ShellNavItem(
    this.icon,
    this.label, {
    super.key,
    this.onPressed,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isSelected ? scheme.primary : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? scheme.primary.withValues(alpha: .14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 46,
            child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, size: 22, color: fg),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.buttonTextStyle.copyWith(
                    color: fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
