// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../bloc/bible_history_cubit.dart';

class BibleHistoryScreen extends StatelessWidget {
  const BibleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleHistoryCubit(),
      child: const _BibleHistoryView(),
    );
  }
}

class _BibleHistoryView extends StatefulWidget {
  const _BibleHistoryView();

  @override
  State<_BibleHistoryView> createState() => _BibleHistoryViewState();
}

class _BibleHistoryViewState extends State<_BibleHistoryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearReading();
  }

  Future<void> _clearSearches() async {
    final ok = await _confirm(
      'Clear search history?',
      "This will permanently delete your search history. This can't be undone.",
    );
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearSearches();
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
          child: BlocBuilder<BibleHistoryCubit, BibleHistoryState>(
            builder: (context, state) => TabBarView(
              controller: _tabController,
              children: [_readingTab(state), _searchesTab(state)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readingTab(BibleHistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.reading.isEmpty) {
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
        for (final group in state.reading) ...[
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
                '${entry.chapterRef ?? ''}${entry.verseNumber != null ? ':${entry.verseNumber}' : ''}',
              ),
              subtitle: Text(
                '${(entry.bibleName?.isNotEmpty ?? false) ? entry.bibleName! : (entry.bibleAbbr ?? '').toUpperCase()} '
                '· ${fmt.format(DateTime.fromMillisecondsSinceEpoch(entry.occurredAt))}',
                style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
              ),
              onTap: () => context.pop(
                ReaderTarget(
                  bibleAbbr: entry.bibleAbbr ?? '',
                  bookId: entry.bookId ?? '',
                  chapterId: entry.refId,
                ),
              ),
            ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _searchesTab(BibleHistoryState state) {
    if (state.isLoading) return const SizedBox.shrink();
    if (state.searches.isEmpty) {
      return const Center(
        child: Text(
          'No searches yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    final fmt = DateFormat('MMM d, h:mm a');
    return ListView.separated(
      itemCount: state.searches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = state.searches[i];
        return ListTile(
          leading: const Icon(Icons.search, color: ThemeColors.mediumGrey),
          title: Text(s.query),
          subtitle: Text(
            fmt.format(DateTime.fromMillisecondsSinceEpoch(s.queriedAt)),
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}
