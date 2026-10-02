import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/app_util.dart';
import '../../../../core/utils/constants/pref_constants.dart';
import '../../../../data/models/bible/bible_search.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../data/repositories/bible/bible_repository.dart';
import '../../../../data/repositories/bible/bible_tracking_repository.dart';
import '../../../../data/repositories/pref_repository.dart';
import '../../../../domain/entities/bible/verse_display.dart';
import '../../../blocs/reader/reader_cubit.dart';

/// Ported from biblelib-android's search feature. Searches run 400 ms after
/// the last keystroke, only for queries of 3+ characters, against one
/// downloaded Bible at a time (defaults to the primary). Tapping a result
/// pops with a [ReaderTarget] for the reader to open.
class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final _bibleRepo = getIt<BibleRepository>();
  final _tracking = getIt<BibleTrackingRepository>();
  final _prefs = getIt<PrefRepository>();
  final _controller = TextEditingController();

  Timer? _debounce;
  int _searchToken = 0;

  List<BibleVersion> _bibles = [];
  String _selectedAbbr = '';
  Map<String, String> _bookNames = {};
  List<VerseDisplay> _results = [];
  List<BibleSearch> _history = [];
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBibles();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBibles() async {
    final downloaded =
        (await _bibleRepo.getBibles()).where((b) => b.isDownloaded).toList();
    final primary = _prefs.getPrefString(PrefConstants.biblePrimaryKey);
    final abbr = downloaded.any((b) => b.abbreviation == primary)
        ? primary
        : (downloaded.isEmpty ? '' : downloaded.first.abbreviation);
    if (!mounted) return;
    setState(() {
      _bibles = downloaded;
      _selectedAbbr = abbr;
    });
    await _loadBookNames(abbr);
  }

  Future<void> _loadBookNames(String abbr) async {
    final names = abbr.isEmpty
        ? <String, String>{}
        : {for (final b in await _bibleRepo.getLocalBooks(abbr)) b.id: b.name};
    if (mounted) setState(() => _bookNames = names);
  }

  Future<void> _loadHistory() async {
    final history = await _tracking.getSearchHistory();
    if (mounted) setState(() => _history = history);
  }

  void _onQueryChanged(String qry) {
    setState(() => _query = qry);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (qry.length >= 3) {
        _performSearch(qry);
      } else if (mounted) {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _performSearch(String qry) async {
    final token = ++_searchToken;
    final abbr = _selectedAbbr.isEmpty
        ? _prefs.getPrefString(PrefConstants.biblePrimaryKey)
        : _selectedAbbr;
    setState(() => _isSearching = true);
    try {
      final results = await _bibleRepo.searchVerses(abbr, qry);
      if (!mounted || token != _searchToken) return;
      setState(() => _results = results);
      if (results.isNotEmpty) {
        await _tracking.recordSearch(qry);
        await _loadHistory();
      }
    } catch (e) {
      logger('Bible search failed: $e');
      if (mounted && token == _searchToken) setState(() => _results = []);
    } finally {
      if (mounted && token == _searchToken) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectBible(String abbr) {
    if (abbr == _selectedAbbr) return;
    setState(() => _selectedAbbr = abbr);
    _loadBookNames(abbr);
    if (_query.length >= 3) _performSearch(_query);
  }

  void _searchFromHistory(String qry) {
    _controller.text = qry;
    _controller.selection = TextSelection.collapsed(offset: qry.length);
    setState(() => _query = qry);
    _performSearch(qry);
  }

  Future<void> _clearHistory() async {
    await _tracking.clearSearchHistory();
    if (mounted) setState(() => _history = []);
  }

  void _clearQuery() {
    _controller.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _results = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Search scriptures...',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: _clearQuery,
                  ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              if (_bibles.length > 1) _filterStrip(),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterStrip() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final b in _bibles)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(b.abbreviation),
                tooltip: b.name,
                selected: b.abbreviation == _selectedAbbr,
                selectedColor: ThemeColors.primary.withValues(alpha: 0.18),
                onSelected: (_) => _selectBible(b.abbreviation),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_bibles.isEmpty) {
      return const Center(child: Text('No downloaded Bibles to search yet.'));
    }
    if (_query.length < 3) return _recentSearches();
    if (_isSearching && _results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (_results.isEmpty) {
      return Center(child: Text('No results for $_query'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${_results.length} results',
            style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _SearchResultItem(
              verse: _results[i],
              query: _query,
              bookName: _bookNames[_results[i].bookId] ?? _results[i].bookId,
              onTap: () => Navigator.pop(
                context,
                ReaderTarget(
                  bibleAbbr: _selectedAbbr,
                  bookId: _results[i].bookId,
                  chapterId: _results[i].chapterId,
                  verseId: _results[i].verseId,
                  searchQuery: _query,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recentSearches() {
    if (_history.isEmpty) {
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
              TextButton(onPressed: _clearHistory, child: const Text('Clear')),
            ],
          ),
        ),
        for (final h in _history)
          ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 20),
            title: Text(h.qry),
            onTap: () => _searchFromHistory(h.qry),
          ),
      ],
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final VerseDisplay verse;
  final String query;
  final String bookName;
  final VoidCallback onTap;

  const _SearchResultItem({
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

    // chapterId looks like "GEN.1": the chapter number is after the dot.
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
