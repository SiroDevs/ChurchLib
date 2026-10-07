// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_bookmark.dart';
import '../../../../data/models/bible/bible_note.dart';
import '../../../../domain/repos/bible/bible_annotation_repo.dart';

String bookmarksNotesKey(String abbr, String verseId) => '$abbr|$verseId';

class BibleBookmarksNotesState {
  final bool isLoading;
  final List<BibleBookmark> bookmarks;
  final List<BibleNote> notes;
  final Set<String> selectedBookmarkKeys;
  final Set<String> selectedNoteKeys;

  const BibleBookmarksNotesState({
    this.isLoading = true,
    this.bookmarks = const [],
    this.notes = const [],
    this.selectedBookmarkKeys = const {},
    this.selectedNoteKeys = const {},
  });

  BibleBookmarksNotesState copyWith({
    bool? isLoading,
    List<BibleBookmark>? bookmarks,
    List<BibleNote>? notes,
    Set<String>? selectedBookmarkKeys,
    Set<String>? selectedNoteKeys,
  }) {
    return BibleBookmarksNotesState(
      isLoading: isLoading ?? this.isLoading,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
      selectedBookmarkKeys: selectedBookmarkKeys ?? this.selectedBookmarkKeys,
      selectedNoteKeys: selectedNoteKeys ?? this.selectedNoteKeys,
    );
  }
}

class BibleBookmarksNotesCubit extends Cubit<BibleBookmarksNotesState> {
  final _repo = getIt<BibleAnnotationRepo>();

  BibleBookmarksNotesCubit() : super(const BibleBookmarksNotesState()) {
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
