// Flutter imports:
import 'package:flutter/material.dart';

Future<T?> showAppWindow<T>(
  BuildContext context, {
  required Widget child,
  double width = 1000,
  double height = 720,
  EdgeInsets inset = const EdgeInsets.all(32),
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: inset,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: child,
      ),
    ),
  );
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
