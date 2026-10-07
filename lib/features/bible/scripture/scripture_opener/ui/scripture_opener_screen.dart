// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/book_picker_dialog.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/chapter_picker_dialog.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/verse_picker_dialog.dart';
import '../cubit/scripture_opener_cubit.dart';

class ScriptureOpenerScreen extends StatelessWidget {
  final String bibleAbbr;
  final String bibleName;

  const ScriptureOpenerScreen({
    super.key,
    required this.bibleAbbr,
    required this.bibleName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScriptureOpenerCubit()..initialize(bibleAbbr, bibleName),
      child: const _ScriptureOpenerView(),
    );
  }
}

class _ScriptureOpenerView extends StatelessWidget {
  const _ScriptureOpenerView();

  Future<void> _pickBook(BuildContext context, ScriptureSearchRowState row) async {
    final cubit = context.read<ScriptureOpenerCubit>();
    final book = await showBookPicker(
      context,
      books: row.books,
      activeBookId: row.selectedBook?.id,
    );
    if (book != null) await cubit.selectBook(row.key, book);
  }

  Future<void> _pickChapter(BuildContext context, ScriptureSearchRowState row) async {
    final cubit = context.read<ScriptureOpenerCubit>();
    final chapter = await showChapterPicker(
      context,
      bookName: row.selectedBook?.name ?? '',
      chapters: row.chapters,
      activeChapterId: row.selectedChapter?.id,
    );
    if (chapter != null) await cubit.selectChapter(row.key, chapter);
  }

  Future<void> _pickVerse(BuildContext context, ScriptureSearchRowState row) async {
    final cubit = context.read<ScriptureOpenerCubit>();
    final numbers = row.verses.map((v) => v.number).toList()..sort();
    final number = await showVersePicker(
      context,
      title: '${row.selectedBook?.name ?? ''} ${row.selectedChapter?.number ?? ''}',
      verseNumbers: numbers,
      activeVerseNumber: row.selectedVerseNumber,
    );
    if (number != null) cubit.selectVerse(row.key, number);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScriptureOpenerCubit, ScriptureOpenerState>(
      builder: (context, state) {
        final cubit = context.read<ScriptureOpenerCubit>();
        final active = state.activeRow;
        final lockedRows = state.rows.where((r) => r.locked).toList();

        return Scaffold(
          appBar: AppBar(title: Text('Open Scripture — ${state.bibleName}')),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: ThemeColors.primary),
                )
              : state.error != null
                  ? Center(child: Text(state.error!))
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lockedRows.isNotEmpty) ...[
                                const Text(
                                  'In queue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final row in lockedRows) _LockedRow(row: row),
                                const SizedBox(height: 20),
                              ],
                              if (active != null) ...[
                                Text(
                                  lockedRows.isEmpty
                                      ? 'Find a scripture'
                                      : 'Add another',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _FieldButton(
                                  label: 'SongBook',
                                  value: active.bookLabel,
                                  onTap: () => _pickBook(context, active),
                                ),
                                const SizedBox(height: 8),
                                _FieldButton(
                                  label: 'Chapter',
                                  value: active.chapterLabel,
                                  enabled: active.canExpandChapter,
                                  loading: active.isLoadingChapters,
                                  onTap: () => _pickChapter(context, active),
                                ),
                                const SizedBox(height: 8),
                                _FieldButton(
                                  label: 'Verse',
                                  value: active.verseLabel,
                                  enabled: active.canExpandVerse,
                                  loading: active.isLoadingVerses,
                                  onTap: () => _pickVerse(context, active),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton(
                                      onPressed: active.isComplete
                                          ? () {
                                              final target =
                                                  cubit.openScripture(active.key);
                                              if (target != null) {
                                                context.pop(target);
                                              }
                                            }
                                          : null,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: ThemeColors.primary,
                                      ),
                                      child: const Text('Open now'),
                                    ),
                                    OutlinedButton(
                                      onPressed: active.isComplete
                                          ? () => cubit.addToQueue(active.key)
                                          : null,
                                      child: const Text('Add to queue'),
                                    ),
                                    if (lockedRows.isNotEmpty || active.isComplete) ...[
                                      OutlinedButton(
                                        onPressed: active.isComplete
                                            ? () async {
                                                final ok = await cubit
                                                    .addToQueueAndClose(active.key);
                                                if (ok && context.mounted) {
                                                  context.pop();
                                                }
                                              }
                                            : null,
                                        child: const Text('Save queue & close'),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: active.isComplete
                                            ? () async {
                                                final target = await cubit
                                                    .addToQueueAndFinish(active.key);
                                                if (target != null && context.mounted) {
                                                  context.pop(target);
                                                }
                                              }
                                            : null,
                                        child: const Text('Save queue & open first'),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}

class _FieldButton extends StatelessWidget {
  final String label;
  final String value;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _FieldButton({
    required this.label,
    required this.value,
    this.enabled = true,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeColors.lightGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Select $label'.toLowerCase() : value,
                    style: TextStyle(
                      fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w600,
                      color: value.isEmpty
                          ? ThemeColors.mediumGrey
                          : ThemeColors.primary,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right, color: ThemeColors.mediumGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  final ScriptureSearchRowState row;
  const _LockedRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: ThemeColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(row.reference)),
        ],
      ),
    );
  }
}
