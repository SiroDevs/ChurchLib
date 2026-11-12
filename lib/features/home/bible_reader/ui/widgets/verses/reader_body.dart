// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../common/widgets/state/skeleton.dart';
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../../presentation/controller/presentation_controller.dart';
import '../../../../../presentation/controller/presentation_sources.dart';
import '../../../cubit/bible_reader_cubit.dart';
import '../dialogs/export.dart';
import 'verse_row.dart';

class ReaderBody extends StatelessWidget {
  const ReaderBody({
    super.key,
    required this.state,
    required this.scrollController,
    required this.viewportKey,
    required this.keyFor,
    required this.onScrollEnd,
    this.presenting = false,
  });

  final BibleReaderState state;
  final ScrollController scrollController;
  final GlobalKey viewportKey;
  final GlobalKey Function(String verseId) keyFor;
  final VoidCallback onScrollEnd;

  final bool presenting;

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
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ).padding(all: 32).center();
    }
    if (state.isLoading && state.verses.isEmpty) {
      return const ReaderLoading();
    }

    final cubit = context.read<BibleReaderCubit>();
    final parallelActive =
        state.multiBibleReaderEnabled &&
        !presenting &&
        state.parallelVerses.isNotEmpty;

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!presenting &&
                  state.activeBook != null &&
                  state.activeChapter != null)
                Text(
                  state.activeChapter!.reference,
                  style: TextStyle(
                    fontSize: state.fontSize * 1.1,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ).padding(bottom: 12, left: 8),
              for (final verse in state.verses)
                VerseRow(
                  key: keyFor(verse.verseId),
                  number: verse.number,
                  text: verse.text,
                  fontSize: state.fontSize.toDouble(),
                  numberColor: presenting
                      ? Colors.white70
                      : ThemeColors.primary,
                  highlightQuery: state.highlightQuery,
                  parallelTexts: parallelActive
                      ? {
                          for (final entry in state.parallelVerses.entries)
                            entry.key:
                                entry.value
                                    .where(
                                      (parallelVerse) =>
                                          parallelVerse.number == verse.number,
                                    )
                                    .map((parallelVerse) => parallelVerse.text)
                                    .firstOrNull ??
                                '',
                        }
                      : const {},
                  parallelLanguages: parallelActive
                      ? {
                          for (final abbreviation in state.parallelVerses.keys)
                            abbreviation: state.languageOf(abbreviation),
                        }
                      : const {},
                  isBookmarked: state.bookmarks.containsKey(verse.verseId),
                  bookmarkColorHex: state.bookmarks[verse.verseId],
                  hasNote: state.notedVerseIds.contains(verse.verseId),
                  onToggleBookmark: () =>
                      cubit.quickToggleBookmark(verse.verseId),
                  onOpenNote: () => _openNote(
                    context,
                    cubit.notesRequestForVerse(verse.verseId),
                  ),
                  isSelected: state.selectedVerseIds.contains(verse.verseId),
                  isSelectionMode: state.isSelectionMode,
                  onToggleSelected: () =>
                      cubit.toggleVerseSelected(verse.verseId),
                  onPresent: () {
                    if (!PresentationController.instance.active) return;
                    presentBible(state, at: state.verses.indexOf(verse));
                  },
                ),
              const SizedBox(height: 48),
            ],
          ).width(double.infinity),
        ),
      ),
    );
  }
}
