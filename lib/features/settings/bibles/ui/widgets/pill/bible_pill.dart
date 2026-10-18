// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../utils/bible_action.dart';
import 'pill_badge.dart';
import 'pill_buttons.dart';
import 'pill_shimmer.dart';

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

  BibleVersion get bible => widget.bible;

  double get progress =>
      (widget.progress ?? bible.downloadProgress).clamp(0.0, 1.0);

  bool get _downloading => widget.progress != null;

  bool get _stopped => !_complete && !_downloading && !bible.downloadFailed;

  bool get _complete =>
      bible.isDownloaded && !bible.downloadFailed && widget.progress == null;

  BibleAction? get _deleteAction =>
      widget.actions.where((a) => a.destructive).firstOrNull;

  Widget _status() {
    final soft = onDark.withValues(alpha: 0.85);
    final label = bible.downloadFailed
        ? ' · Download failed'
        : _downloading
        ? ' · Fetching verses'
        : _stopped
        ? ' · Download stopped'
        : null;
    return Row(
      children: [
        Text(
          '${bible.languageName.toUpperCase()} BIBLE',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: soft),
        ).flexible(),
        if (label != null)
          Text(label, style: TextStyle(fontSize: 12, color: soft))
        else
          Icon(Icons.check_circle, size: 14, color: soft).padding(left: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = bible.downloadFailed ? Colors.red.shade700 : badgeOrange;
    final fill = _downloading ? progress.clamp(0.08, 1.0) : 0.0;
    final radius = BorderRadius.circular(18);

    final pill = Container(
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
            if (_downloading) PillShimmer(animation: _shimmer),
            Row(
              children: [
                PillBadge(
                  bible: bible,
                  progress: progress,
                  downloading: _downloading,
                ).constrained(width: 60, height: 60).padding(all: 8),
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bible.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: onDark,
                      ),
                    ),
                    Text(
                      bible.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: onDark),
                    ),
                    _status(),
                  ],
                ).expanded(),
                PillDownloadButtons(
                  complete: _complete,
                  downloading: _downloading,
                  onStop: widget.onStop,
                  onRestart: widget.onRestart,
                  onContinue: widget.onContinue,
                  onDelete: _deleteAction?.onTap,
                ),
              ],
            ),
            if (_complete && widget.actions.isNotEmpty)
              PillActionBar(actions: widget.actions, visible: _hovering),
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: pill,
    );
  }
}
