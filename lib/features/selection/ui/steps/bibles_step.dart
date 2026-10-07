// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/widgets/state/error_view.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../bloc/selection_bloc.dart';
import '../../utils/bible_grouping.dart';
import '../widgets/bible_tile.dart';
import '../widgets/selection_title.dart';

class BiblesStep extends StatefulWidget {
  const BiblesStep({super.key});

  @override
  State<BiblesStep> createState() => _BiblesStepState();
}

class _BiblesStepState extends State<BiblesStep> {
  String _query = '';
  GroupingMode _grouping = GroupingMode.regions;
  final Map<String, bool> _expanded = {};
  final Map<String, String> _countryFilters = {};

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SelectionBloc>();
    if (bloc.state.availableBibles.isEmpty &&
        bloc.state.bibleStatus != BibleStatus.error) {
      bloc.add(const BiblesRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionBloc, SelectionState>(
      builder: (context, state) => switch (state.bibleStatus) {
        BibleStatus.loading => const Center(
            child: CircularProgressIndicator(color: ThemeColors.primary),
          ),
        BibleStatus.error => ErrorView(
            message: state.bibleMessage,
            onRetry: () => context
                .read<SelectionBloc>()
                .add(const BiblesRequested()),
          ),
        BibleStatus.loaded => _buildPicker(context, state),
        BibleStatus.saving ||
        BibleStatus.saved ||
        BibleStatus.saveFailed =>
          const SizedBox.shrink(),
      },
    );
  }

  /// Search box and the grouping strip share one row when there is room;
  /// on narrow screens the strip drops under the search box.
  Widget _searchAndStrip() {
    final search = TextField(
      onChanged: (v) => setState(() => _query = v),
      decoration: InputDecoration(
        hintText: 'Search name, abbreviation or language',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    final strip = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final mode in GroupingMode.values) ...[
            ChoiceChip(
              label: Text(mode.label),
              selected: _grouping == mode,
              onSelected: (_) => setState(() => _grouping = mode),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 700
          ? Row(
              children: [
                search.expanded(),
                const SizedBox(width: 16),
                Expanded(child: strip).expanded(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [search, const SizedBox(height: 10), strip],
            ),
    );
  }

  Widget _buildPicker(BuildContext context, SelectionState state) {
    final q = _query.trim().toLowerCase();
    final filtered = state.availableBibles.where((b) {
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.abbreviation.toLowerCase().contains(q) ||
          b.language.name.toLowerCase().contains(q);
    }).toList();

    final entries = buildEntries(
      filtered,
      _grouping,
      expanded: _expanded,
      countryFilters: _countryFilters,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectionTitle(
                title: 'Choose your Bibles',
                noun: 'bibles',
                count: state.selectedAbbrs.length,
                max: state.maxSelections,
              ),
              const SizedBox(height: 4),
              const Text(
                'Your first pick is the primary Bible',
                style: TextStyle(fontSize: 13, color: ThemeColors.grey),
              ),
              const SizedBox(height: 12),
              _searchAndStrip(),
              const SizedBox(height: 4),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No Bibles match your search'))
              : _buildList(context, state, entries),
        ),
      ],
    );
  }

  Widget _buildList(
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