// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../common/windows/window_frame.dart';
import '../../../../common/navigator/route_names.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../bloc/bibles_cubit.dart';
import 'widgets/bible_row.dart';
import 'widgets/secondary_section.dart';

class BiblesScreen extends StatelessWidget {
  const BiblesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BiblesCubit(),
      child: _BiblesView(embedded: embedded),
    );
  }
}

class _BiblesView extends StatelessWidget {
  const _BiblesView({required this.embedded});

  final bool embedded;

  void _addMore(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.pushNamed(RouteNames.biblelibSetup);
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
      appBar: embedded
          ? null
          : WindowAppBar(
              icon: Icons.library_books_outlined,
              title: 'Manage Your Bibles',
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
                  if (embedded)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _addMore(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add more translations'),
                      ),
                    ),
                  for (final bible in state.bibles)
                    BibleRow(
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
                    SecondarySection(state: state),
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
