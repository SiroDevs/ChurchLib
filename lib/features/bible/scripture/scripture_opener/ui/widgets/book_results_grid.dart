// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_book.dart';
import 'field_pointer_arrow.dart';

const _otBookCount = 39;

class BookResultsGrid extends StatelessWidget {
  const BookResultsGrid({
    super.key,
    required this.books,
    required this.selectedBookId,
    required this.onSelect,
  });

  final List<BibleBook> books;
  final String? selectedBookId;
  final ValueChanged<BibleBook> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ordered = [...books]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final ot = ordered.take(_otBookCount).toList();
    final nt = ordered.skip(_otBookCount).toList();
    final otShade = scheme.primaryContainer.withValues(alpha: 0.18);
    final ntShade = scheme.tertiaryContainer.withValues(alpha: 0.18);
    final longest = ot.length > nt.length ? ot.length : nt.length;
    final rowCount = (longest + 1) ~/ 2;

    Widget pair(List<BibleBook> list, int row, Color shade) => Expanded(
          flex: 2,
          child: Container(
            color: shade,
            child: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(child: _cell(list, row * 2 + i)),
              ],
            ),
          ),
        );

    return Column(
      children: [
        const FieldPointerArrow(fieldIndex: fieldIndexBook),
        Material(
          color: scheme.surface,
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Column(
              children: [
                Row(
                  children: [
                    _header('Old Testament', otShade, scheme.primary),
                    _header('New Testament', ntShade, scheme.tertiary),
                  ],
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rowCount,
                    itemBuilder: (_, row) => Row(
                      children: [
                        pair(ot, row, otShade),
                        pair(nt, row, ntShade),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(String text, Color shade, Color color) => Expanded(
        child: Container(
          color: shade,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      );

  Widget _cell(List<BibleBook> list, int index) {
    if (index >= list.length) return const SizedBox.shrink();
    return _BookCell(
      book: list[index],
      isSelected: list[index].id == selectedBookId,
      onTap: () => onSelect(list[index]),
    );
  }
}

class _BookCell extends StatelessWidget {
  const _BookCell({
    required this.book,
    required this.isSelected,
    required this.onTap,
  });

  final BibleBook book;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Center(
              child: Text(
                book.abbreviation.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
