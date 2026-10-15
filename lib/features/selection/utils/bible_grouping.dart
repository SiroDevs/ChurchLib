// Project imports:
import '../../../data/sources/remote/bible/bible_dtos.dart';
import 'region_mapper.dart';

part 'bible_grid_entries.dart';

enum GroupingMode {
  regions('Regions'),
  countries('Countries'),
  languages('Languages'),
  none('None');

  const GroupingMode(this.label);
  final String label;
}

const allFilter = 'All';
const unspecifiedCountryName = 'Unspecific';

const _priorityLanguages = ['English', 'French'];
const _priorityCountry = 'Kenya';

class CountryRef {
  const CountryRef(this.id, this.name);
  final String id;
  final String name;
}

extension BibleCountries on BibleInfoDto {
  List<CountryRef> get countryRefs {
    final refs = [for (final c in countries) CountryRef(c.id, c.name)];
    return refs.isEmpty
        ? const [CountryRef(RegionMapper.unspecifiedCountryId, unspecifiedCountryName)]
        : refs;
  }
}

class FilterOption {
  const FilterOption(this.name, this.count);
  final String name;
  final int count;
}

List<GridEntry> buildEntries(
  List<BibleInfoDto> bibles,
  GroupingMode mode, {
  required Map<String, bool> expanded,
  required Map<String, String> countryFilters,
}) =>
    switch (mode) {
      GroupingMode.none => [for (final b in bibles) BibleEntry(b)],
      GroupingMode.languages => _languageEntries(bibles, expanded),
      GroupingMode.countries => _countryEntries(bibles, expanded),
      GroupingMode.regions => _regionEntries(bibles, expanded, countryFilters),
    };

int _languagePriority(String language) {
  if (language.toLowerCase() == 'unspecified') return 1 << 30;
  final i = _priorityLanguages
      .indexWhere((p) => p.toLowerCase() == language.toLowerCase());
  return i >= 0 ? i : _priorityLanguages.length;
}

int _countryPriority(String country, List<BibleInfoDto> items) {
  bool has(String lang) =>
      items.any((b) => b.language.name.toLowerCase() == lang.toLowerCase());
  if (country.toLowerCase() == unspecifiedCountryName.toLowerCase()) {
    return 1 << 30;
  }
  if (has(_priorityLanguages[0])) return 0;
  if (has(_priorityLanguages[1])) return 1;
  if (country.toLowerCase() == _priorityCountry.toLowerCase()) return 2;
  return 3;
}

int _regionPriority(String region) {
  if (region == RegionMapper.unspecified) return 1 << 30;
  final i = RegionMapper.priority.indexOf(region);
  return i == -1 ? RegionMapper.priority.length : i;
}

List<MapEntry<String, List<BibleInfoDto>>> _sortCountries(
  Map<String, List<BibleInfoDto>> groups,
) =>
    groups.entries.toList()
      ..sort((a, b) {
        final p = _countryPriority(a.key, a.value)
            .compareTo(_countryPriority(b.key, b.value));
        return p != 0 ? p : a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

List<GridEntry> _languageEntries(
  List<BibleInfoDto> bibles,
  Map<String, bool> expanded,
) {
  final groups = <String, List<BibleInfoDto>>{};
  for (final b in bibles) {
    final name = b.language.name.trim().isEmpty ? 'Unspecified' : b.language.name;
    (groups[name] ??= []).add(b);
  }
  final ordered = groups.entries.toList()
    ..sort((a, b) {
      final p = _languagePriority(a.key).compareTo(_languagePriority(b.key));
      return p != 0 ? p : a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });
  return [
    for (final e in ordered) ...[
      HeaderEntry('language:${e.key}', e.key, e.value.length),
      if (expanded['language:${e.key}'] ?? true)
        for (final b in e.value) BibleEntry(b),
    ],
  ];
}

Map<String, List<BibleInfoDto>> _byCountry(List<BibleInfoDto> bibles) {
  final map = <String, List<BibleInfoDto>>{};
  for (final b in bibles) {
    for (final c in b.countryRefs) {
      (map[c.name] ??= []).add(b);
    }
  }
  return map;
}

List<GridEntry> _countryEntries(
  List<BibleInfoDto> bibles,
  Map<String, bool> expanded,
) =>
    [
      for (final e in _sortCountries(_byCountry(bibles))) ...[
        HeaderEntry('country:${e.key}', e.key, e.value.length),
        if (expanded['country:${e.key}'] ?? true)
          for (final b in e.value) BibleEntry(b),
      ],
    ];

class _RegionBucket {
  final items = <BibleInfoDto>[];
  final _seen = <String>{};
  final byCountry = <String, List<BibleInfoDto>>{};

  void addDistinct(BibleInfoDto b) {
    if (_seen.add(b.abbreviation)) items.add(b);
  }
}

List<GridEntry> _regionEntries(
  List<BibleInfoDto> bibles,
  Map<String, bool> expanded,
  Map<String, String> countryFilters,
) {
  final byRegion = <String, _RegionBucket>{};
  for (final b in bibles) {
    for (final c in b.countryRefs) {
      final bucket =
          byRegion.putIfAbsent(RegionMapper.continentFor(c.id), _RegionBucket.new);
      bucket.addDistinct(b);
      (bucket.byCountry[c.name] ??= []).add(b);
    }
  }

  final regions = byRegion.keys.toList()
    ..sort((a, b) {
      final p = _regionPriority(a).compareTo(_regionPriority(b));
      return p != 0 ? p : a.toLowerCase().compareTo(b.toLowerCase());
    });

  final out = <GridEntry>[];
  for (final region in regions) {
    final key = 'continent:$region';
    final bucket = byRegion[region]!;
    out.add(HeaderEntry(key, region, bucket.items.length));
    if (!(expanded[key] ?? true)) continue;

    final countries = _sortCountries(bucket.byCountry);
    final chosen = countryFilters[key];
    final selected = chosen != null &&
            (chosen == allFilter || bucket.byCountry.containsKey(chosen))
        ? chosen
        : allFilter;

    out.add(
      CountryFilterEntry(
        continentKey: key,
        selected: selected,
        options: [
          FilterOption(allFilter, bucket.items.length),
          for (final c in countries) FilterOption(c.key, c.value.length),
        ],
      ),
    );
    final shown = selected == allFilter
        ? bucket.items
        : bucket.byCountry[selected] ?? const <BibleInfoDto>[];
    out.addAll(shown.map(BibleEntry.new));
  }
  return out;
}
