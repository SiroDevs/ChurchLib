// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../../presentation/controller/presentation_controller.dart';
import '../../../../../presentation/controller/presentation_sources.dart';
import '../../../bloc/bible_reader_cubit.dart';
import '../dialogs/dialogs.dart';
import 'verse_row.dart';

class ReaderBody extends StatelessWidget {
  const ReaderBody({
    super.key,
    required this.state,
    required this.scrollController,
    required this.viewportKey,
    required this.keyFor,
    required this.onScrollEnd,
  });

  final BibleReaderState state;
  final ScrollController scrollController;
  final GlobalKey viewportKey;
  final GlobalKey Function(String verseId) keyFor;
  final VoidCallback onScrollEnd;

  Future<void> _openNote(BuildContext context, NotesRequest? request) async {
    if (request == null) return;
    final cubit = context.read<BibleReaderCubit>();
    await showNoteEditor(context, request);
    await cubit.refreshNotedVerses();
  }

  @override
  Widget build(BuildContext context) {
    if (state.error != null && state.verses.isEmpty) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 56,
              color: ThemeColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<BibleReaderCubit>().initialize(),
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ).padding(all: 32).center();
    }
    if (state.isLoading && state.verses.isEmpty) {
      return CircularProgressIndicator(color: ThemeColors.primary).center();
    }

    final cubit = context.read<BibleReaderCubit>();
    final parallelActive =
        state.multiBibleReaderEnabled && state.parallelVerses.isNotEmpty;

    return Directionality(
      textDirection: state.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          onScrollEnd();
          return false;
        },
        child: SingleChildScrollView(
          key: viewportKey,
          controller: scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final v in state.verses)
                VerseRow(
                  key: keyFor(v.verseId),
                  number: v.number,
                  text: v.text,
                  fontSize: state.fontSize.toDouble(),
                  highlightQuery: state.highlightQuery,
                  parallelTexts: parallelActive
                      ? {
                          for (final e in state.parallelVerses.entries)
                            e.key:
                                e.value
                                    .where((p) => p.number == v.number)
                                    .map((p) => p.text)
                                    .firstOrNull ??
                                '',
                        }
                      : const {},
                  parallelLanguages: parallelActive
                      ? {
                          for (final abbr in state.parallelVerses.keys)
                            abbr: state.languageOf(abbr),
                        }
                      : const {},
                  isBookmarked: state.bookmarks.containsKey(v.verseId),
                  bookmarkColorHex: state.bookmarks[v.verseId],
                  hasNote: state.notedVerseIds.contains(v.verseId),
                  onToggleBookmark: () =>
                      cubit.quickToggleBookmark(v.verseId),
                  onOpenNote: () => _openNote(
                    context,
                    cubit.notesRequestForVerse(v.verseId),
                  ),
                  isSelected: state.selectedVerseIds.contains(v.verseId),
                  isSelectionMode: state.isSelectionMode,
                  onToggleSelected: () =>
                      cubit.toggleVerseSelected(v.verseId),
                  onPresent: () {
                    if (!PresentationController.instance.active) return;
                    presentBible(state, at: state.verses.indexOf(v));
                  },
                ),
              const SizedBox(height: 48),
            ],
          )
              .width(double.infinity),
          ),
        ),
      );
  }
}
