part of 'bibles_step.dart';

mixin BiblesStepList on State<BiblesStep> {
  Map<String, bool> get _expanded;
  Map<String, String> get _countryFilters;

  Widget buildList(
    BuildContext context,
    SelectionState state,
    List<GridEntry> entries,
  ) {
    final slivers = <Widget>[];
    var i = 0;
    while (i < entries.length) {
      if (entries[i] is BibleEntry) {
        final run = <BibleEntry>[];
        while (i < entries.length && entries[i] is BibleEntry) {
          run.add(entries[i++] as BibleEntry);
        }
        if (run.length == 1) {
          slivers.add(
            SliverToBoxAdapter(child: _entry(context, state, run.first)),
          );
        } else {
          slivers.add(
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                mainAxisExtent: 84,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, n) => _entry(context, state, run[n]),
                childCount: run.length,
              ),
            ),
          );
        }
      } else {
        slivers.add(SliverToBoxAdapter(child: _entry(context, state, entries[i])));
        i++;
      }
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverMainAxisGroup(slivers: slivers),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _entry(BuildContext context, SelectionState state, GridEntry entry) {
    switch (entry) {
      case HeaderEntry():
        final open = _expanded[entry.key] ?? true;
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Material(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _expanded[entry.key] = !open),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: entry.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.primary,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '   ${entry.count} ${entry.count == 1 ? 'bible' : 'bibles'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ThemeColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(open ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
        );
      case CountryFilterEntry():
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (final option in entry.options) ...[
                FilterChip(
                  label: Text('${option.name} (${option.count})'),
                  selected: option.name == entry.selected,
                  onSelected: (_) => setState(
                    () => _countryFilters[entry.continentKey] = option.name,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        );
      case BibleEntry():
        final b = entry.bible;
        return BibleTile(
          bible: b,
          selected: state.selectedAbbrs.contains(b.abbreviation),
          isPrimary: state.selectedAbbrs.isNotEmpty &&
              state.selectedAbbrs.first == b.abbreviation,
          atLimit: state.selectedAbbrs.length >= state.maxSelections,
        );
    }
  }
}
