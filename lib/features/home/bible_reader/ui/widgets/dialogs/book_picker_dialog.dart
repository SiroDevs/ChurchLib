// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../data/models/bible/bible_book.dart';

const _otBookCount = 39;

Future<BibleBook?> showBookPicker(
  BuildContext context, {
  required List<BibleBook> books,
  required String? activeBookId,
}) {
  return showDialog<BibleBook>(
    context: context,
    builder: (_) => _BookPickerDialog(books: books, activeBookId: activeBookId),
  );
}

class _BookPickerDialog extends StatefulWidget {
  final List<BibleBook> books;
  final String? activeBookId;
  const _BookPickerDialog({required this.books, required this.activeBookId});

  @override
  State<_BookPickerDialog> createState() => _BookPickerDialogState();
}

class _BookPickerDialogState extends State<_BookPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ordered = [...widget.books]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final ot = ordered.take(_otBookCount).toList();
    final nt = ordered.skip(_otBookCount).toList();

    List<BibleBook> filter(List<BibleBook> src) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return src;
      return src
          .where((b) =>
              b.name.toLowerCase().contains(q) ||
              b.nameLong.toLowerCase().contains(q) ||
              b.abbreviation.toLowerCase().contains(q))
          .toList();
    }

    final singleList = nt.isEmpty;

    Widget list(List<BibleBook> src) {
      final items = filter(src);
      if (items.isEmpty) {
        return const Center(child: Text('No books found'));
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final b = items[i];
          final active = b.id == widget.activeBookId;
          return ListTile(
            dense: true,
            selected: active,
            selectedColor: ThemeColors.primary,
            leading: SizedBox(
              width: 36,
              child: Text(
                b.id.length > 3 ? b.id.substring(0, 3) : b.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
            ),
            title: Text(b.name),
            onTap: () => Navigator.pop(context, b),
          );
        },
      );
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: DefaultTabController(
          length: singleList ? 1 : 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (!singleList)
                const TabBar(
                  labelColor: ThemeColors.primary,
                  indicatorColor: ThemeColors.primary,
                  tabs: [
                    Tab(text: 'Old Testament'),
                    Tab(text: 'New Testament'),
                  ],
                ),
              Expanded(
                child: singleList
                    ? list(ordered)
                    : TabBarView(children: [list(ot), list(nt)]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
