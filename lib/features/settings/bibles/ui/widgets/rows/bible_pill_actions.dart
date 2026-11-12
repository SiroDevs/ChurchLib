// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../l10n/gen/app_localizations.dart';
import '../../../utils/bible_action.dart';

class BiblePillDownloadButtons extends StatelessWidget {
  const BiblePillDownloadButtons({
    super.key,
    required this.downloading,
    required this.complete,
    required this.onStop,
    required this.onRestart,
    required this.onContinue,
    required this.deleteAction,
  });

  final bool downloading;
  final bool complete;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;
  final VoidCallback? onContinue;
  final BibleAction? deleteAction;

  ButtonStyle _style(Color color) => TextButton.styleFrom(
    foregroundColor: color,
    minimumSize: const Size(0, 24),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: const TextStyle(fontSize: 13),
  );

  @override
  Widget build(BuildContext context) {
    if (complete) return const SizedBox(width: 12);
    final l10n = AppLocalizations.of(context)!;
    if (downloading) {
      if (onStop == null) return const SizedBox(width: 12);
      return TextButton(
        onPressed: onStop,
        style: _style(onDark),
        child: Text(l10n.stopAction),
      ).padding(right: 8);
    }

    final hasAny =
        onRestart != null || onContinue != null || deleteAction != null;
    if (!hasAny) return const SizedBox(width: 12);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onRestart != null)
          TextButton(
            onPressed: onRestart,
            style: _style(onDark),
            child: Text(l10n.restartAction),
          ),
        if (onContinue != null)
          TextButton(
            onPressed: onContinue,
            style: _style(onDark),
            child: Text(l10n.continueAction),
          ),
        if (deleteAction != null)
          TextButton(
            onPressed: deleteAction!.onTap,
            style: _style(Colors.red.shade300),
            child: Text(l10n.deleteAction),
          ),
      ],
    ).padding(right: 8);
  }
}

class BiblePillActionBar extends StatelessWidget {
  const BiblePillActionBar({
    super.key,
    required this.actions,
    required this.visible,
  });

  final List<BibleAction> actions;
  final bool visible;

  ButtonStyle _style(Color color) => TextButton.styleFrom(
    foregroundColor: color,
    visualDensity: VisualDensity.compact,
  );

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
                      style: _style(
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
