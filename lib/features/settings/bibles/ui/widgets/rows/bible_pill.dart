// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../utils/bible_action.dart';

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

  ButtonStyle _buttonStyle(Color color) => TextButton.styleFrom(
    foregroundColor: color,
    visualDensity: VisualDensity.compact,
  );

  ButtonStyle _compactStyle(Color color) => TextButton.styleFrom(
    foregroundColor: color,
    minimumSize: const Size(0, 24),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: const TextStyle(fontSize: 13),
  );

  Widget? _downloadButtons() {
    if (_complete) return null;
    if (_downloading) {
      if (widget.onStop == null) return null;
      return TextButton(
        onPressed: widget.onStop,
        style: _compactStyle(onDark),
        child: const Text('Stop'),
      ).padding(right: 8);
    }
    final delete = _deleteAction;
    final hasAny =
        widget.onRestart != null || widget.onContinue != null || delete != null;
    if (!hasAny) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onRestart != null)
          TextButton(
            onPressed: widget.onRestart,
            style: _compactStyle(onDark),
            child: const Text('Restart'),
          ),
        if (widget.onContinue != null)
          TextButton(
            onPressed: widget.onContinue,
            style: _compactStyle(onDark),
            child: const Text('Continue'),
          ),
        if (delete != null)
          TextButton(
            onPressed: delete.onTap,
            style: _compactStyle(Colors.red.shade300),
            child: const Text('Delete'),
          ),
      ],
    ).padding(right: 8);
  }

  Widget _actionBar() => AnimatedOpacity(
    opacity: _hovering ? 1 : 0,
    duration: const Duration(milliseconds: 120),
    child: IgnorePointer(
      ignoring: !_hovering,
      child:
          Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in widget.actions)
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

  Widget _badge() {
    if (bible.downloadFailed) {
      return const Icon(Icons.error_outline, color: onDark).decorated(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(16),
      );
    }
    if (_downloading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            color: onDark,
            backgroundColor: onDark.withValues(alpha: 0.25),
            strokeWidth: 3,
          ),
          Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: onDark,
                ),
              )
              .center()
              .decorated(color: badgeOrange, shape: BoxShape.circle)
              .padding(all: 7),
        ],
      );
    }
    final abbr = bible.abbreviation.toUpperCase();
    return Text(
          abbr.length > 3 ? abbr.substring(0, 3) : abbr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: onDark,
          ),
        )
        .alignment(Alignment.center)
        .decorated(color: badgeOrange, borderRadius: BorderRadius.circular(16));
  }

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
            if (_downloading) _shimmerLayer(),
            Row(
              children: [
                _badge().constrained(width: 60, height: 60).padding(all: 8),
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
                _downloadButtons() ?? const SizedBox(width: 12),
              ],
            ),
            if (_complete && widget.actions.isNotEmpty) _actionBar(),
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
