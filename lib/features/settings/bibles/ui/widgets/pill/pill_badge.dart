// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../utils/bible_action.dart';

/// Square badge at the left of a pill: abbreviation, progress ring or error.
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.bible,
    required this.progress,
    required this.downloading,
  });

  final BibleVersion bible;
  final double progress;
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    if (bible.downloadFailed) {
      return const Icon(Icons.error_outline, color: onDark).decorated(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(16),
      );
    }
    if (downloading) {
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
}
