// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../domain/entities/bible/verse_display.dart';
import '../../cubit/bible_search_cubit.dart';

class BibleFilterStrip extends StatelessWidget {
  final BibleSearchState state;
  final ValueChanged<String> onSelect;

  const BibleFilterStrip({super.key, required this.state, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final b in state.bibles)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(b.abbreviation),
                tooltip: b.name,
                selected: b.abbreviation == state.selectedAbbr,
                selectedColor: ThemeColors.primary.withValues(alpha: 0.18),
                onSelected: (_) => onSelect(b.abbreviation),
              ),
            ),
        ],
      ),
    );
  }
}

class BibleSearchResults extends StatelessWidget {
  final BibleSearchState state;
  final void Function(VerseDisplay verse) onTapResult;
  final ValueChanged<String> onTapHistory;
  final VoidCallback onClearHistory;

  const BibleSearchResults({
    super.key,
    required this.state,
    required this.onTapResult,
    required this.onTapHistory,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (state.bibles.isEmpty) {
      return const Center(child: Text('No downloaded Bibles to search yet.'));
    }
    if (state.query.length < 3) return _recentSearches();
    if (state.isSearching && state.results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.results.isEmpty) {
      return Center(child: Text('No results for ${state.query}'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${state.results.length} results',
            style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: state.results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final verse = state.results[i];
              return SearchResultItem(
                verse: verse,
                query: state.query,
                bookName: state.bookNames[verse.bookId] ?? verse.bookId,
                onTap: () => onTapResult(verse),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _recentSearches() {
    if (state.history.isEmpty) {
      return const Center(
        child: Text(
          'Type at least 3 letters to search.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent searches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
              ),
              TextButton(onPressed: onClearHistory, child: const Text('Clear')),
            ],
          ),
        ),
        for (final h in state.history)
          ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 20),
            title: Text(h.query),
            onTap: () => onTapHistory(h.query),
          ),
      ],
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final VerseDisplay verse;
  final String query;
  final String bookName;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.verse,
    required this.query,
    required this.bookName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = TextStyle(color: theme.colorScheme.onSurface, height: 1.4);
    final hit = base.copyWith(
      fontWeight: FontWeight.bold,
      backgroundColor: ThemeColors.primary1.withValues(alpha: 0.35),
    );

    final spans = <TextSpan>[];
    final lower = verse.text.toLowerCase();
    final q = query.toLowerCase();
    var start = 0;
    var idx = q.isEmpty ? -1 : lower.indexOf(q);
    while (idx >= 0) {
      spans.add(TextSpan(text: verse.text.substring(start, idx), style: base));
      spans.add(
        TextSpan(text: verse.text.substring(idx, idx + q.length), style: hit),
      );
      start = idx + q.length;
      idx = lower.indexOf(q, start);
    }
    spans.add(TextSpan(text: verse.text.substring(start), style: base));

    final chapterNumber = verse.chapterId.contains('.')
        ? verse.chapterId.substring(verse.chapterId.indexOf('.') + 1)
        : verse.chapterId;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$bookName $chapterNumber:${verse.number}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(children: spans),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
