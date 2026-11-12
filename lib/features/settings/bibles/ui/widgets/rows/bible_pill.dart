// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../utils/bible_action.dart';
import 'bible_pill_actions.dart';
import 'bible_pill_status.dart';

class BiblePill extends StatefulWidget {
  const BiblePill({
    super.key,
    required this.bible,
    this.progress,
    this.actions = const [],
    this.onRestart,
    this.onContinue,
    this.onStop,
  });

  final BibleVersion bible;
  final double? progress;
  final List<BibleAction> actions;
  final VoidCallback? onRestart;
  final VoidCallback? onContinue;
  final VoidCallback? onStop;

  @override
  State<BiblePill> createState() => _BiblePillState();
}

class _BiblePillState extends State<BiblePill>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;

  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  BibleVersion get _bible => widget.bible;

  double get _progress =>
      (widget.progress ?? _bible.downloadProgress).clamp(0.0, 1.0);

  bool get _downloading => widget.progress != null;

  bool get _stopped => !_complete && !_downloading && !_bible.downloadFailed;

  bool get _complete =>
      _bible.isDownloaded && !_bible.downloadFailed && widget.progress == null;

  BibleAction? get _deleteAction =>
      widget.actions.where((action) => action.destructive).firstOrNull;

  @override
  void initState() {
    super.initState();
    _syncShimmer();
  }

  @override
  void didUpdateWidget(covariant BiblePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncShimmer();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  void _syncShimmer() {
    if (_downloading) {
      if (!_shimmer.isAnimating) _shimmer.repeat();
    } else if (_shimmer.isAnimating) {
      _shimmer.stop();
    }
  }

  Widget _shimmerLayer() => IgnorePointer(
    child: AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) => Align(
        alignment: Alignment(-2.4 + 4.8 * _shimmer.value, 0),
        child: FractionallySizedBox(
          widthFactor: 0.4,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final border = _bible.downloadFailed ? Colors.red.shade700 : badgeOrange;
    final fill = _downloading ? _progress.clamp(0.08, 1.0) : 0.0;
    final radius = BorderRadius.circular(18);
    final deleteAction = _deleteAction;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: radius,
          border: Border.all(color: border, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              if (fill > 0)
                FractionallySizedBox(
                  widthFactor: fill,
                  heightFactor: 1,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mutedOrange, mutedOrange, darkBrown],
                      ),
                    ),
                  ),
                ),
              if (_downloading) _shimmerLayer(),
              Row(
                children: [
                  BiblePillBadge(
                    bible: _bible,
                    downloading: _downloading,
                    progress: _progress,
                  ).constrained(width: 60, height: 60).padding(all: 8),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bible.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onDark,
                        ),
                      ),
                      Text(
                        _bible.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: onDark),
                      ),
                      BiblePillStatus(
                        bible: _bible,
                        downloading: _downloading,
                        stopped: _stopped,
                      ),
                    ],
                  ).expanded(),
                  BiblePillDownloadButtons(
                    downloading: _downloading,
                    complete: _complete,
                    onStop: widget.onStop,
                    onRestart: widget.onRestart,
                    onContinue: widget.onContinue,
                    deleteAction: deleteAction,
                  ),
                ],
              ),
              if (_complete && widget.actions.isNotEmpty)
                BiblePillActionBar(actions: widget.actions, visible: _hovering),
            ],
          ),
        ),
      ),
    );
  }
}
