// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../data/models/bible/bible_version.dart';
import 'bible_pill.dart';

class BibleAction {
  const BibleAction(this.icon, this.label, this.onTap, {this.destructive = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class HoverBibleRow extends StatefulWidget {
  const HoverBibleRow({
    super.key,
    required this.bible,
    required this.progress,
    required this.actions,
    required this.onRestart,
    required this.onContinue,
    this.leading,
  });

  final BibleVersion bible;
  final double? progress;
  final List<BibleAction> actions;
  final VoidCallback onRestart;
  final VoidCallback onContinue;
  final Widget? leading;

  @override
  State<HoverBibleRow> createState() => _HoverBibleRowState();
}

class _HoverBibleRowState extends State<HoverBibleRow> {
  bool _hovering = false;

  Widget _downloadButtons(bool failed) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed)
              TextButton(
                onPressed: widget.onRestart,
                child: const Text('Restart'),
              ),
            TextButton(
              onPressed: widget.onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  Widget _actionBar(ColorScheme scheme) => Visibility(
        visible: _hovering,
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final action in widget.actions)
                TextButton.icon(
                  onPressed: action.onTap,
                  icon: Icon(action.icon, size: 18),
                  label: Text(action.label),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        action.destructive ? scheme.error : scheme.primary,
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bible = widget.bible;
    final progress = (widget.progress ?? bible.downloadProgress).clamp(0.0, 1.0);
    final downloading = widget.progress != null;
    final needsAction =
        bible.downloadFailed || (!bible.isDownloaded && !downloading);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                if (widget.leading != null) widget.leading!,
                Expanded(child: BiblePill(bible: bible, progress: progress)),
                if (needsAction) _downloadButtons(bible.downloadFailed),
              ],
            ),
            if (widget.actions.isNotEmpty)
              _actionBar(Theme.of(context).colorScheme),
          ],
        ),
      ),
    );
  }
}
