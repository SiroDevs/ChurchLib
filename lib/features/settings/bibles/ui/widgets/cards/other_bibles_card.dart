import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../../../../common/utils/theme/shape_utils.dart';
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../../../../domain/repos/bible/bible_selection_repo.dart';
import '../../../bloc/bibles_cubit.dart';
import '../../../utils/bible_action.dart';
import '../rows/bible_pill.dart';
import '../rows/section_header_row.dart';

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
    final canAdd =
        state.multiBibleEnabled &&
        state.secondaryBibles.length < bibleMaxSecondaryBibles;

    final rows = <Widget>[];
    for (final bible in bibles) {
      rows.add(
        BiblePill(
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
        ).padding(horizontal: 16, top: 8),
      );
    }

    return Column(
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
        )
        .padding(top: 4, bottom: 10)
        .card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: outlinedShape(scheme, BorderRadius.circular(10)),
        );
  }
}
