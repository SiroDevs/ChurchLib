// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/bible/bible_history.dart';
import '../../../data/models/bible/bible_search.dart';
import '../../../domain/repos/bible/bible_tracking_repo.dart';
import '../../home/bible_reader/bloc/reader_cubit.dart';

/// Ported from biblelib-android's history feature: Reading and Searches
/// tabs. Reading entries are grouped under "Today" / "Yesterday" / a date
/// heading, same as Android's `HistoryViewModel.groupByDate`. Tapping a
/// reading entry pops a [ReaderTarget].
class BibleHistoryScreen extends StatefulWidget {
  const BibleHistoryScreen({super.key});

  @override
  State<BibleHistoryScreen> createState() => _BibleHistoryScreenState();
}

class _HistoryGroup {
  final String dateLabel;
  final List<BibleHistory> entries;
  _HistoryGroup(this.dateLabel, this.entries);
}

class _BibleHistoryScreenState extends State<BibleHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _tracking = getIt<BibleTrackingRepo>();
  late final TabController _tabController;

  bool _isLoading = true;
  List<_HistoryGroup> _reading = [];
  List<BibleSearch> _searches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final reading = await _tracking.getReadingHistory();
    final searches = await _tracking.getSearchHistory();
    if (!mounted) return;
    setState(() {
      _reading = _groupByDate(reading);
      _searches = searches;
      _isLoading = false;
    });
  }

  List<_HistoryGroup> _groupByDate(List<BibleHistory> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fmt = DateFormat('MMMM d, yyyy');

    final groups = <String, List<BibleHistory>>{};
    for (final e in entries) {
      final d = DateTime.fromMillisecondsSinceEpoch(e.readAt);
      final day = DateTime(d.year, d.month, d.day);
      final label = day == today
          ? 'Today'
          : (day == yesterday ? 'Yesterday' : fmt.format(d));
      (groups[label] ??= []).add(e);
    }
    // Entries already arrive sorted DESC by readAt; preserve that order.
    return [for (final e in groups.entries) _HistoryGroup(e.key, e.value)];
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _clearReading() async {
    final ok = await _confirm(
      'Clear reading history?',
      "This will permanently delete your reading history. This can't be undone.",
    );
    if (!ok) return;
    await _tracking.clearHistory();
    await _load();
  }

  Future<void> _clearSearches() async {
    final ok = await _confirm(
      'Clear search history?',
      "This will permanently delete your search history. This can't be undone.",
    );
    if (!ok) return;
    await _tracking.clearSearchHistory();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeColors.primary,
          indicatorColor: ThemeColors.primary,
          tabs: const [Tab(text: 'Reading'), Tab(text: 'Searches')],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () =>
                _tabController.index == 0 ? _clearReading() : _clearSearches(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: TabBarView(
            controller: _tabController,
            children: [_readingTab(), _searchesTab()],
          ),
        ),
      ),
    );
  }

  Widget _readingTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (_reading.isEmpty) {
      return const Center(
        child: Text(
          'No reading history yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    final fmt = DateFormat('h:mm a');
    return ListView(
      children: [
        for (final group in _reading) ...[
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              group.dateLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final entry in group.entries)
            ListTile(
              leading: Icon(
                Icons.menu_book_rounded,
                color: ThemeColors.primary.withValues(alpha: 0.6),
              ),
              title: Text(
                '${entry.chapterRef}${entry.verseNumber != null ? ':${entry.verseNumber}' : ''}',
              ),
              subtitle: Text(
                '${entry.bibleName.isNotEmpty ? entry.bibleName : entry.bibleAbbr.toUpperCase()} '
                '· ${fmt.format(DateTime.fromMillisecondsSinceEpoch(entry.readAt))}',
                style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
              ),
              onTap: () => Navigator.pop(
                context,
                ReaderTarget(
                  bibleAbbr: entry.bibleAbbr,
                  bookId: entry.bookId,
                  chapterId: entry.chapterId,
                ),
              ),
            ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _searchesTab() {
    if (_isLoading) return const SizedBox.shrink();
    if (_searches.isEmpty) {
      return const Center(
        child: Text(
          'No searches yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    final fmt = DateFormat('MMM d, h:mm a');
    return ListView.separated(
      itemCount: _searches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = _searches[i];
        return ListTile(
          leading: const Icon(Icons.search, color: ThemeColors.mediumGrey),
          title: Text(s.qry),
          subtitle: Text(
            fmt.format(DateTime.fromMillisecondsSinceEpoch(s.queriedAt)),
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}
