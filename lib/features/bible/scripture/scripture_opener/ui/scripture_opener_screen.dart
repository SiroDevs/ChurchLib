// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../common/windows/window_frame.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/book_picker_dialog.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/chapter_picker_dialog.dart';
import '../../../../home/bible_reader/ui/widgets/dialogs/verse_picker_dialog.dart';
import '../cubit/scripture_opener_cubit.dart';

part 'opener_widgets.dart';

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
          appBar: WindowAppBar(
            icon: Icons.auto_stories_outlined,
            title: 'Open Scripture — ${state.bibleName}',
          ),
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
                                                Navigator.of(context).pop(target);
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
                                                  Navigator.of(context).pop();
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
                                                  Navigator.of(context).pop(target);
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
