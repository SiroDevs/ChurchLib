import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../common/utils/dialog_utils.dart';
import '../../../../common/windows/window_frame.dart';
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

  Future<void> _clearReading() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Clear reading history?',
      message: "This will permanently delete your reading history. This can't be undone.",
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearReading();
  }

  Future<void> _clearSearches() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Clear search history?',
      message: "This will permanently delete your search history. This can't be undone.",
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowAppBar(
        icon: Icons.history,
        title: 'History',
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
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: BlocBuilder<BibleHistoryCubit, BibleHistoryState>(
          builder: (context, state) => TabBarView(
            controller: _tabController,
            children: [_readingTab(state), _searchesTab(state)],
          ),
        ),
      )
          .center(),
    );
  }

  Widget _readingTab(BibleHistoryState state) {
    if (state.isLoading) {
      return CircularProgressIndicator(color: ThemeColors.primary).center();
    }
    if (state.reading.isEmpty) {
      return Text(
        'No reading history yet.',
        style: TextStyle(color: ThemeColors.mediumGrey),
      )
          .center();
    }
    final fmt = DateFormat('h:mm a');
    return ListView(
      children: [
        for (final group in state.reading) ...[
          Text(
            group.dateLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
              .padding(horizontal: 16, vertical: 6)
              .decorated(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              )
              .width(double.infinity),
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
              onTap: () => Navigator.of(context).pop(
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
      return Text(
        'No searches yet.',
        style: TextStyle(color: ThemeColors.mediumGrey),
      )
          .center();
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
