// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
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
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.error_outline, color: _onDark),
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
          Padding(
            padding: const EdgeInsets.all(7),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _badgeOrange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _onDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    final abbr = bible.abbreviation.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: _badgeOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        abbr.length > 3 ? abbr.substring(0, 3) : abbr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _onDark,
        ),
      ),
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
        Flexible(
          child: Text(
            '${bible.languageName.toUpperCase()} BIBLE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: soft),
          ),
        ),
        if (label != null)
          Text(label, style: TextStyle(fontSize: 12, color: soft))
        else
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(Icons.check_circle, size: 14, color: soft),
          ),
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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(width: 60, height: 60, child: _badge()),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
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
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
