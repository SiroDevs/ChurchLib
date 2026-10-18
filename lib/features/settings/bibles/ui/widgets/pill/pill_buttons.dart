// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../utils/bible_action.dart';

ButtonStyle _compactStyle(Color color) => TextButton.styleFrom(
  foregroundColor: color,
  minimumSize: const Size(0, 24),
  padding: const EdgeInsets.symmetric(horizontal: 10),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  textStyle: const TextStyle(fontSize: 13),
);

ButtonStyle _buttonStyle(Color color) => TextButton.styleFrom(
  foregroundColor: color,
  visualDensity: VisualDensity.compact,
);

/// Stop / Restart / Continue / Delete buttons shown on the right of a pill
/// while a download is running or after it was interrupted.
class PillDownloadButtons extends StatelessWidget {
  const PillDownloadButtons({
    super.key,
    required this.complete,
    required this.downloading,
    this.onStop,
    this.onRestart,
    this.onContinue,
    this.onDelete,
  });

  final bool complete;
  final bool downloading;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;
  final VoidCallback? onContinue;
  final VoidCallback? onDelete;

  static const _none = SizedBox(width: 12);

  @override
  Widget build(BuildContext context) {
    if (complete) return _none;
    if (downloading) {
      if (onStop == null) return _none;
      return TextButton(
        onPressed: onStop,
        style: _compactStyle(onDark),
        child: const Text('Stop'),
      ).padding(right: 8);
    }
    if (onRestart == null && onContinue == null && onDelete == null) {
      return _none;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onRestart != null)
          TextButton(
            onPressed: onRestart,
            style: _compactStyle(onDark),
            child: const Text('Restart'),
          ),
        if (onContinue != null)
          TextButton(
            onPressed: onContinue,
            style: _compactStyle(onDark),
            child: const Text('Continue'),
          ),
        if (onDelete != null)
          TextButton(
            onPressed: onDelete,
            style: _compactStyle(Colors.red.shade300),
            child: const Text('Delete'),
          ),
      ],
    ).padding(right: 8);
  }
}

/// Hover-only action bar that fades in over the right edge of a pill.
/// Must be a direct child of a [Stack].
class PillActionBar extends StatelessWidget {
  const PillActionBar({super.key, required this.actions, required this.visible});

  final List<BibleAction> actions;
  final bool visible;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: visible ? 1 : 0,
    duration: const Duration(milliseconds: 120),
    child: IgnorePointer(
      ignoring: !visible,
      child:
          Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in actions)
                    TextButton.icon(
                      onPressed: action.onTap,
                      icon: Icon(action.icon, size: 18),
                      label: Text(action.label),
                      style: _buttonStyle(
                        action.destructive ? Colors.red.shade300 : onDark,
                      ),
                    ),
                ],
              )
              .padding(left: 32, right: 8)
              .decorated(
                gradient: LinearGradient(
                  colors: [
                    darkBrown.withValues(alpha: 0),
                    darkBrown,
                    darkBrown,
                  ],
                  stops: const [0, 0.25, 1],
                ),
              ),
    ),
  ).positioned(top: 20, right: 0, bottom: 0);
}
