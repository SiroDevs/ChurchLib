part of 'bible_grouping.dart';

sealed class GridEntry {
  const GridEntry();
}

class HeaderEntry extends GridEntry {
  const HeaderEntry(this.key, this.title, this.count);
  final String key;
  final String title;
  final int count;
}

class CountryFilterEntry extends GridEntry {
  const CountryFilterEntry({
    required this.continentKey,
    required this.options,
    required this.selected,
  });
  final String continentKey;
  final List<FilterOption> options;
  final String selected;
}

class BibleEntry extends GridEntry {
  const BibleEntry(this.bible);
  final BibleInfoDto bible;
}
