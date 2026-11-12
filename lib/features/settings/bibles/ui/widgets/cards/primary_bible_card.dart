// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../../../../l10n/gen/app_localizations.dart';

class PrimaryBibleCard extends StatelessWidget {
  const PrimaryBibleCard({
    super.key,
    required this.primary,
    required this.onTap,
  });

  final BibleVersion? primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bible = primary;
    if (bible == null) return Text(l10n.noPrimaryBible);

    final scheme = Theme.of(context).colorScheme;
    final abbr = bible.abbreviation.toUpperCase();
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
                abbr.length > 3 ? abbr.substring(0, 3) : abbr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              )
              .alignment(Alignment.center)
              .decorated(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              )
              .constrained(width: 50, height: 50),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bible.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.biblePrimaryLabel(bible.languageName.toUpperCase()),
                style: TextStyle(fontSize: 11, color: scheme.primary),
              ),
            ],
          ).expanded(),
        ],
      ).padding(all: 12),
    ).card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.primary),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }
}
