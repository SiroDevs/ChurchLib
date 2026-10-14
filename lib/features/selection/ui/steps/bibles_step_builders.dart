part of 'bibles_step.dart';

mixin BiblesStepBuilders on State<BiblesStep> {
  Widget buildList(
    BuildContext context,
    SelectionState state,
    List<GridEntry> entries,
  );

  String get _query;
  set _query(String value);
  GroupingMode get _grouping;
  set _grouping(GroupingMode value);
  Map<String, bool> get _expanded;
  Map<String, String> get _countryFilters;

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
        Column(
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
        )
            .padding(left: 24, top: 16, right: 24, bottom: 0),
        Expanded(
          child: filtered.isEmpty
              ? Text('No Bibles match your search').center()
              : buildList(context, state, entries),
        ),
      ],
    );
  }
}
