// Flutter imports:
import 'package:flutter/material.dart';

const double _kWindowRadius = 16;

Future<T?> showAppWindow<T>(
  BuildContext context, {
  required Widget child,
  double width = 1000,
  double height = 720,
  EdgeInsets inset = const EdgeInsets.all(32),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      insetPadding: inset,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: _WindowFrame(child: child),
      ),
    ),
  );
}

class _WindowFrame extends StatelessWidget {
  const _WindowFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(_kWindowRadius);

    final borderColor = isDark ? const Color(0xFF8E8E8E) : const Color(0xFF9E9E9E);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.35),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.28),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(color: theme.colorScheme.surface, child: child),
    );
  }
}

class WindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WindowAppBar({
    super.key,
    required this.icon,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.bottom,
    this.onClose,
  });

  final IconData icon;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onClose;

  static const double barHeight = 48;

  @override
  Size get preferredSize =>
      Size.fromHeight(barHeight + (bottom?.preferredSize.height ?? 0) + 1);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: barHeight,
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(icon, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: titleWidget ??
                      Text(
                        title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                ),
                ...actions,
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          if (bottom != null) bottom!,
          Divider(height: 1, color: scheme.outlineVariant),
        ],
      ),
    );
  }
}