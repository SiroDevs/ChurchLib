// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../data/models/bible/bible_version.dart';
import '../../../../../domain/repos/bible/bible_selection_repo.dart';
import '../../bloc/bibles_cubit.dart';
import 'hover_bible_row.dart';
import 'section_header_row.dart';

class OtherBiblesCard extends StatelessWidget {
  const OtherBiblesCard({
    super.key,
    required this.bibles,
    required this.state,
    required this.cubit,
    required this.onDelete,
  });

  final List<BibleVersion> bibles;
  final BiblesState state;
  final BiblesCubit cubit;
  final ValueChanged<BibleVersion> onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canAdd = state.multiBibleEnabled &&
        state.secondaryBibles.length < bibleMaxSecondaryBibles;

    final rows = <Widget>[];
    for (final bible in bibles) {
      if (rows.isNotEmpty) {
        rows.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      rows.add(
        HoverBibleRow(
          bible: bible,
          progress: state.downloadProgress[bible.abbreviation],
          actions: [
            if (canAdd)
              BibleAction(
                Icons.add_circle_outline,
                'Set as secondary',
                () => cubit.toggleSecondaryBible(bible.abbreviation),
              ),
            BibleAction(
              Icons.delete_outline,
              'Delete',
              () => onDelete(bible),
              destructive: true,
            ),
          ],
          onRestart: () => cubit.restartDownload(bible.abbreviation),
          onContinue: () => cubit.retryDownload(bible.abbreviation),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            SectionHeaderRow(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              left: SectionHeaderRow.label(context, 'Other Bibles'),
              right: SectionHeaderRow.label(
                context,
                'Hover a Bible to set it as Secondary',
              ),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}
