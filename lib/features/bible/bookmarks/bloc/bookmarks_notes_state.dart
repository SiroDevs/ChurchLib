part of 'bookmarks_notes_cubit.dart';

class BookmarksNotesState {
  final bool isLoading;
  final List<BibleBookmark> bookmarks;
  final List<BibleNote> notes;
  final Set<String> selectedBookmarkKeys;
  final Set<String> selectedNoteKeys;

  const BookmarksNotesState({
    this.isLoading = true,
    this.bookmarks = const [],
    this.notes = const [],
    this.selectedBookmarkKeys = const {},
    this.selectedNoteKeys = const {},
  });

  BookmarksNotesState copyWith({
    bool? isLoading,
    List<BibleBookmark>? bookmarks,
    List<BibleNote>? notes,
    Set<String>? selectedBookmarkKeys,
    Set<String>? selectedNoteKeys,
  }) {
    return BookmarksNotesState(
      isLoading: isLoading ?? this.isLoading,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
      selectedBookmarkKeys: selectedBookmarkKeys ?? this.selectedBookmarkKeys,
      selectedNoteKeys: selectedNoteKeys ?? this.selectedNoteKeys,
    );
  }
}
