// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../domain/repos/bible/bible_selection_repo.dart';
import '../bloc/bibles_cubit.dart';

/// Ported from biblelib-android's Bibles management screen: shows every
/// selected translation with its status (downloaded, downloading, failed),
/// a primary badge, per-row actions, and a section for choosing which
/// translations appear in the reader's parallel view.
class BiblesScreen extends StatelessWidget {
  const BiblesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BiblesCubit(),
      child: const _BiblesView(),
    );
  }
}

class _BiblesView extends StatelessWidget {
  const _BiblesView();

  Future<void> _addMore(BuildContext context) async {
    await context.pushNamed(RouteNames.biblelibSetup);
    if (context.mounted) context.read<BiblesCubit>().load();
  }

  Future<void> _confirmDelete(BuildContext context, BibleVersion bible) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${bible.name}?'),
        content: const Text(
          "This deletes its downloaded content from this device. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<BiblesCubit>().deleteBible(bible.abbreviation);
    }
  }

  Future<void> _pickPrimary(BuildContext context, BiblesState state) async {
    final downloaded = state.bibles.where((b) => b.isDownloaded).toList();
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose your primary Bible'),
        children: [
          for (final b in downloaded)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, b.abbreviation),
              child: Row(
                children: [
                  if (b.abbreviation == state.primaryAbbr)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.check, size: 18, color: ThemeColors.primary),
                    ),
                  Expanded(child: Text('${b.abbreviation} · ${b.name}')),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<BiblesCubit>().setPrimaryBible(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibles'),
        actions: [
          IconButton(
            tooltip: 'Add more translations',
            icon: const Icon(Icons.add),
            onPressed: () => _addMore(context),
          ),
        ],
      ),
      body: BlocBuilder<BiblesCubit, BiblesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColors.primary),
            );
          }
          if (state.bibles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 56, color: ThemeColors.mediumGrey),
                    const SizedBox(height: 16),
                    const Text('No Bibles yet.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _addMore(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                      ),
                      child: const Text('Add a translation'),
                    ),
                  ],
                ),
              ),
            );
          }

          final downloadedCount =
              state.bibles.where((b) => b.isDownloaded).length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  for (final bible in state.bibles)
                    _BibleRow(
                      bible: bible,
                      isPrimary: bible.abbreviation == state.primaryAbbr,
                      progress: state.downloadProgress[bible.abbreviation],
                      onSetPrimary: () => context
                          .read<BiblesCubit>()
                          .setPrimaryBible(bible.abbreviation),
                      onRetry: () => context
                          .read<BiblesCubit>()
                          .retryDownload(bible.abbreviation),
                      onRestart: () => context
                          .read<BiblesCubit>()
                          .restartDownload(bible.abbreviation),
                      onDelete: () => _confirmDelete(context, bible),
                    ),
                  if (downloadedCount > 1) ...[
                    const Divider(height: 32),
                    _SecondarySection(state: state),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _pickPrimary(context, state),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Change primary Bible'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BibleRow extends StatelessWidget {
  final BibleVersion bible;
  final bool isPrimary;
  final double? progress;
  final VoidCallback onSetPrimary;
  final VoidCallback onRetry;
  final VoidCallback onRestart;
  final VoidCallback onDelete;

  const _BibleRow({
    required this.bible,
    required this.isPrimary,
    required this.progress,
    required this.onSetPrimary,
    required this.onRetry,
    required this.onRestart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final downloading = progress != null;
    final failed = !bible.isDownloaded && !downloading && bible.downloadFailed;
    final pending = !bible.isDownloaded && !downloading && !failed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPrimary ? ThemeColors.primary : ThemeColors.lightGrey,
            width: isPrimary ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          bible.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'primary':
                        onSetPrimary();
                      case 'retry':
                        onRetry();
                      case 'restart':
                        onRestart();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (bible.isDownloaded && !isPrimary)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Text('Make primary'),
                      ),
                    if (failed || pending)
                      const PopupMenuItem(
                        value: 'retry',
                        child: Text('Download'),
                      ),
                    if (failed)
                      const PopupMenuItem(
                        value: 'restart',
                        child: Text('Restart download'),
                      ),
                    const PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            Text(
              '${bible.abbreviation} · ${bible.languageName}',
              style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
            ),
            const SizedBox(height: 8),
            if (downloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress! > 0 ? progress : null,
                  minHeight: 6,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).round()}% downloaded',
                style: const TextStyle(fontSize: 11, color: ThemeColors.grey),
              ),
            ] else if (failed) ...[
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: ThemeColors.error),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Download failed',
                      style: TextStyle(fontSize: 12, color: ThemeColors.error),
                    ),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ] else if (pending) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondarySection extends StatelessWidget {
  final BiblesState state;
  const _SecondarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BiblesCubit>();
    final candidates = state.bibles
        .where((b) => b.isDownloaded && b.abbreviation != state.primaryAbbr)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Parallel Bibles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
              ),
              Switch(
                value: state.multiBibleEnabled,
                activeThumbColor: ThemeColors.primary,
                onChanged: cubit.setMultiBibleEnabled,
              ),
            ],
          ),
          Text(
            'Shown alongside your primary Bible in the reader '
            '(up to $bibleMaxSecondaryBibles, in this order).',
            style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
          ),
          const SizedBox(height: 8),
          for (final b in candidates)
            _SecondaryTile(
              bible: b,
              index: state.secondaryBibles.indexOf(b.abbreviation),
              total: state.secondaryBibles.length,
              enabled: state.multiBibleEnabled,
            ),
        ],
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  final BibleVersion bible;

  /// -1 when not selected as a secondary Bible.
  final int index;
  final int total;
  final bool enabled;

  const _SecondaryTile({
    required this.bible,
    required this.index,
    required this.total,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BiblesCubit>();
    final selected = index >= 0;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: CheckboxListTile(
        value: selected,
        activeColor: ThemeColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: enabled
            ? (_) => cubit.toggleSecondaryBible(bible.abbreviation)
            : null,
        title: Text('${bible.abbreviation} · ${bible.name}'),
        secondary: selected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    onPressed: enabled && index > 0
                        ? () => cubit.moveSecondaryBible(bible.abbreviation, -1)
                        : null,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_downward, size: 18),
                    onPressed: enabled && index < total - 1
                        ? () => cubit.moveSecondaryBible(bible.abbreviation, 1)
                        : null,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
