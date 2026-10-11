import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../../../data/models/bible/bible_version.dart';

const _badgeOrange = Color(0xFFE1550F);
const _mutedOrange = Color(0xFFB05A2E);
const _darkBrown = Color(0xFF3A1300);
const _onDark = Colors.white;

class BiblePill extends StatelessWidget {
  const BiblePill({super.key, required this.bible, required this.progress});

  final BibleVersion bible;
  final double progress;

  bool get _downloading => !bible.isDownloaded && !bible.downloadFailed;

  Widget _badge() {
    if (bible.downloadFailed) {
      return const Icon(Icons.error_outline, color: _onDark)
          .decorated(
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
            color: _onDark,
            backgroundColor: _onDark.withValues(alpha: 0.25),
            strokeWidth: 3,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _onDark,
            ),
          )
              .center()
              .decorated(color: _badgeOrange, shape: BoxShape.circle)
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
        color: _onDark,
      ),
    )
        .alignment(Alignment.center)
        .decorated(
          color: _badgeOrange,
          borderRadius: BorderRadius.circular(16),
        );
  }

  Widget _status() {
    final soft = _onDark.withValues(alpha: 0.85);
    final label = bible.downloadFailed
        ? ' · Download failed'
        : _downloading
            ? ' · Fetching verses'
            : null;
    return Row(
      children: [
        Text(
          '${bible.languageName.toUpperCase()} BIBLE',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: soft),
        )
            .flexible(),
        if (label != null)
          Text(label, style: TextStyle(fontSize: 12, color: soft))
        else
          Icon(Icons.check_circle, size: 14, color: soft).padding(left: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = bible.downloadFailed ? Colors.red.shade700 : _badgeOrange;
    final fill = _downloading ? progress.clamp(0.08, 1.0) : 0.0;
    final radius = BorderRadius.circular(18);

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: _darkBrown,
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
                      colors: [_mutedOrange, _mutedOrange, _darkBrown],
                    ),
                  ),
                ),
              ),
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
                        color: _onDark,
                      ),
                    ),
                    Text(
                      bible.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: _onDark),
                    ),
                    _status(),
                  ],
                )
                    .expanded(),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
