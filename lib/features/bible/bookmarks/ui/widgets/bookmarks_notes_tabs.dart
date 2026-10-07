// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../data/models/bible/bible_note.dart';
import '../../../reader/ui/widgets/verses/verse_row.dart' show parseHexColor;
import '../../bloc/bookmarks_notes_cubit.dart';

class BookmarksTab extends StatelessWidget {
  final BookmarksNotesState state;
  final void Function(String abbr, String bookId, String chapterId) onOpen;

  const BookmarksTab({super.key, required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.bookmarks.isEmpty) {
      return const Center(
        child: Text(
          'No bookmarks yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    return ListView.separated(
      itemCount: state.bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = state.bookmarks[i];
        final key = bookmarksNotesKey(b.bibleAbbr, b.verseId);
        final selected = state.selectedBookmarkKeys.contains(key);
        final selectionMode = state.selectedBookmarkKeys.isNotEmpty;
        final chapterNumber = b.chapterId.contains('.')
            ? b.chapterId.substring(b.chapterId.indexOf('.') + 1)
            : b.chapterId;
        final cubit = context.read<BookmarksNotesCubit>();
        return ListTile(
          selected: selected,
          selectedTileColor: ThemeColors.primary.withValues(alpha: 0.1),
          leading: Icon(
            Icons.bookmark_rounded,
            color: parseHexColor(b.colorHex) ?? ThemeColors.primary,
          ),
          title: Text('${b.bookId} — $chapterNumber'),
          subtitle: Text(
            b.bibleAbbr.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => selectionMode
              ? cubit.toggleBookmark(b)
              : onOpen(b.bibleAbbr, b.bookId, b.chapterId),
          onLongPress: () => cubit.toggleBookmark(b),
        );
      },
    );
  }
}

class NotesTab extends StatelessWidget {
  final BookmarksNotesState state;
  final void Function(BibleNote note) onEdit;

  const NotesTab({super.key, required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.notes.isEmpty) {
      return const Center(
        child: Text(
          'No notes yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    return ListView.separated(
      itemCount: state.notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = state.notes[i];
        final key = bookmarksNotesKey(n.bibleAbbr, n.verseId);
        final selected = state.selectedNoteKeys.contains(key);
        final selectionMode = state.selectedNoteKeys.isNotEmpty;
        final cubit = context.read<BookmarksNotesCubit>();
        return ListTile(
          selected: selected,
          selectedTileColor: ThemeColors.primary.withValues(alpha: 0.1),
          leading: const Icon(Icons.sticky_note_2, color: ThemeColors.primary),
          title: Text(
            n.title.isNotEmpty ? n.title : n.verseText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            n.noteText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => selectionMode ? cubit.toggleNote(n) : onEdit(n),
          onLongPress: () => cubit.toggleNote(n),
        );
      },
    );
  }
}
