// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../data/models/bible/bible_version.dart';
import '../../bloc/bibles_cubit.dart';
import 'hover_bible_row.dart';
import 'section_header_row.dart';

class SecondaryBiblesCard extends StatefulWidget {
  const SecondaryBiblesCard({
    super.key,
    required this.state,
    required this.cubit,
    required this.onDelete,
  });

  final BiblesState state;
  final BiblesCubit cubit;
  final ValueChanged<BibleVersion> onDelete;

  @override
  State<SecondaryBiblesCard> createState() => _SecondaryBiblesCardState();
}

class _SecondaryBiblesCardState extends State<SecondaryBiblesCard> {
  bool _reordering = false;

  Widget _reorderControls(String abbr, int index, int count) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Move up',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.arrow_upward, size: 18),
            onPressed: index > 0
                ? () => widget.cubit.moveSecondaryBible(abbr, -1)
                : null,
          ),
          IconButton(
            tooltip: 'Move down',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.arrow_downward, size: 18),
            onPressed: index < count - 1
                ? () => widget.cubit.moveSecondaryBible(abbr, 1)
                : null,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final secondary = state.secondaryBibles;
    final scheme = Theme.of(context).colorScheme;
    final showControls = _reordering && secondary.length > 1;

    final rows = <Widget>[];
    for (var i = 0; i < secondary.length; i++) {
      final abbr = secondary[i];
      final bible = state.bibles.where((b) => b.abbreviation == abbr).firstOrNull;
      if (bible == null) continue;
      if (rows.isNotEmpty) {
        rows.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      rows.add(
        HoverBibleRow(
          bible: bible,
          progress: state.downloadProgress[abbr],
          leading: showControls
              ? _reorderControls(abbr, i, secondary.length)
              : null,
          actions: [
            BibleAction(
              Icons.remove_circle_outline,
              'Remove from secondary',
              () => widget.cubit.toggleSecondaryBible(abbr),
            ),
            BibleAction(
              Icons.delete_outline,
              'Delete',
              () => widget.onDelete(bible),
              destructive: true,
            ),
          ],
          onRestart: () => widget.cubit.restartDownload(abbr),
          onContinue: () => widget.cubit.retryDownload(abbr),
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
              left: SectionHeaderRow.label(
                context,
                secondary.length == 1
                    ? '1 secondary bible'
                    : '${secondary.length} secondary bibles',
              ),
              right: secondary.length > 1
                  ? TextButton.icon(
                      onPressed: () => setState(() => _reordering = !_reordering),
                      icon: const Icon(Icons.swap_vert, size: 18),
                      label: Text(_reordering ? 'Done' : 'Reorder'),
                    )
                  : SectionHeaderRow.label(context, 'Hover a Bible to remove it'),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }
}
