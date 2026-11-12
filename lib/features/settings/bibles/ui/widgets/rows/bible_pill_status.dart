// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../../../../l10n/gen/app_localizations.dart';
import '../../../utils/bible_action.dart';

/// Progress or abbreviation badge for a Bible download.
class BiblePillBadge extends StatelessWidget {
  const BiblePillBadge({
    super.key,
    required this.bible,
    required this.downloading,
    required this.progress,
  });

  final BibleVersion bible;
  final bool downloading;
  final double progress;

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
    final abbreviation = bible.abbreviation.toUpperCase();
    return Text(
          abbreviation.length > 3 ? abbreviation.substring(0, 3) : abbreviation,
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

/// Language and download state displayed beneath a Bible name.
class BiblePillStatus extends StatelessWidget {
  const BiblePillStatus({
    super.key,
    required this.bible,
    required this.downloading,
    required this.stopped,
  });

  final BibleVersion bible;
  final bool downloading;
  final bool stopped;

  @override
  Widget build(BuildContext context) {
    final soft = onDark.withValues(alpha: 0.85);
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = bible.downloadFailed
        ? l10n.downloadFailedStatus
        : downloading
        ? l10n.fetchingVersesStatus
        : stopped
        ? l10n.downloadStoppedStatus
        : null;
    return Row(
      children: [
        Text(
          l10n.bibleLanguageLabel(bible.languageName.toUpperCase()),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: soft),
        ).flexible(),
        if (statusLabel != null)
          Text(statusLabel, style: TextStyle(fontSize: 12, color: soft))
        else
          Icon(Icons.check_circle, size: 14, color: soft).padding(left: 6),
      ],
    );
  }
}
