// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/utils/display/dialog_utils.dart';
import '../../../../common/windows/window_frame.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.clearReadingHistoryQuestion,
      message: l10n.clearReadingHistoryMessage,
      confirmLabel: l10n.deleteAction,
      destructive: true,
    );
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearReading();
  }

  Future<void> _clearSearches() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.clearSearchHistoryQuestion,
      message: l10n.clearSearchHistoryMessage,
      confirmLabel: l10n.deleteAction,
      destructive: true,
    );
    if (ok && mounted) await context.read<BibleHistoryCubit>().clearSearches();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: WindowAppBar(
        icon: Icons.history,
        title: l10n.historyTitle,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeColors.primary,
          indicatorColor: ThemeColors.primary,
          tabs: [
            Tab(text: l10n.historyReading),
            Tab(text: l10n.historySearches),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.clearAction,
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
      ).center(),
    );
  }

  Widget _readingTab(BibleHistoryState state) {
    if (state.isLoading) {
      return CircularProgressIndicator(color: ThemeColors.primary).center();
    }
    if (state.reading.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noReadingHistory,
        style: TextStyle(color: ThemeColors.mediumGrey),
      ).center();
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
        AppLocalizations.of(context)!.noSearchesYet,
        style: TextStyle(color: ThemeColors.mediumGrey),
      ).center();
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
