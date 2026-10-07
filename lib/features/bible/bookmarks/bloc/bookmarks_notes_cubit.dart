// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_bookmark.dart';
import '../../../../data/models/bible/bible_note.dart';
import '../../../../domain/repos/bible/bible_annotation_repo.dart';

part 'bookmarks_notes_state.dart';

String bookmarksNotesKey(String abbr, String verseId) => '$abbr|$verseId';

class BookmarksNotesCubit extends Cubit<BookmarksNotesState> {
  final _repo = getIt<BibleAnnotationRepo>();

  BookmarksNotesCubit() : super(const BookmarksNotesState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final bookmarks = await _repo.getAllBookmarks();
    final notes = await _repo.getAllNotes();
    emit(state.copyWith(
      isLoading: false,
      bookmarks: bookmarks,
      notes: notes,
      selectedBookmarkKeys: {},
      selectedNoteKeys: {},
    ));
  }

  void toggleBookmark(BibleBookmark b) {
    final key = bookmarksNotesKey(b.bibleAbbr, b.verseId);
    final next = {...state.selectedBookmarkKeys};
    if (!next.remove(key)) next.add(key);
    emit(state.copyWith(selectedBookmarkKeys: next));
  }

  void toggleNote(BibleNote n) {
    final key = bookmarksNotesKey(n.bibleAbbr, n.verseId);
    final next = {...state.selectedNoteKeys};
    if (!next.remove(key)) next.add(key);
    emit(state.copyWith(selectedNoteKeys: next));
  }

  Future<void> deleteSelectedBookmarks() async {
    final toDelete = state.bookmarks
        .where((b) => state.selectedBookmarkKeys
            .contains(bookmarksNotesKey(b.bibleAbbr, b.verseId)))
        .toList();
    await _repo.deleteBookmarks(toDelete);
    await load();
  }

  Future<void> deleteSelectedNotes() async {
    final toDelete = state.notes
        .where((n) => state.selectedNoteKeys
            .contains(bookmarksNotesKey(n.bibleAbbr, n.verseId)))
        .toList();
    await _repo.deleteNotes(toDelete);
    await load();
  }

  Future<void> clearAllBookmarks() async {
    await _repo.deleteBookmarks(state.bookmarks);
    await load();
  }

  Future<void> clearAllNotes() async {
    await _repo.deleteNotes(state.notes);
    await load();
  }
}
