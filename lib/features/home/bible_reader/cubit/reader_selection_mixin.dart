part of 'bible_reader_cubit.dart';

mixin ReaderSelectionMixin on Cubit<BibleReaderState> {
  BibleAnnotationRepo get _annotations;

  Future<void> quickToggleBookmark(String verseId) async {
    final abbr = state.activeBibleAbbr;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (bookId == null || chapterId == null) return;

    if (state.bookmarks.containsKey(verseId)) {
      await _annotations.removeBookmarks(abbr, [verseId]);
      emit(state.copyWith(bookmarks: withoutBookmark(state.bookmarks, verseId)));
    } else {
      await _annotations.setBookmarks(abbr, [verseId], bookId, chapterId);
      emit(state.copyWith(bookmarks: withBookmarks(state.bookmarks, [verseId], null)));
    }
  }

  void toggleVerseSelected(String verseId) {
    emit(state.copyWith(
      selectedVerseIds: toggleVerseSelection(state.selectedVerseIds, verseId),
    ));
  }

  void clearSelection() => emit(state.copyWith(
        selectedVerseIds: const {},
        pendingHighlightColor: null,
      ));

  void chooseHighlightColor(String colorHex) =>
      emit(state.copyWith(pendingHighlightColor: colorHex));

  void cancelPendingHighlight() =>
      emit(state.copyWith(pendingHighlightColor: null));

  List<VerseDisplay> get _selectedVersesSorted =>
      selectedVersesSorted(state.verses, state.selectedVerseIds);

  NotesRequest _buildNotesRequest(VerseDisplay verse) => buildNotesRequest(
        bibleAbbr: state.activeBibleAbbr,
        verse: verse,
        book: state.activeBook,
        chapter: state.activeChapter,
      );

  NotesRequest? notesRequestForVerse(String verseId) {
    for (final v in state.verses) {
      if (v.verseId == verseId) return _buildNotesRequest(v);
    }
    return null;
  }

  NotesRequest? openNotesForSelection() {
    if (state.selectedVerseIds.length != 1) return null;
    final request = notesRequestForVerse(state.selectedVerseIds.first);
    if (request == null) return null;
    emit(state.copyWith(selectedVerseIds: const {}));
    return request;
  }

  Future<void> _applyHighlight() async {
    final color = state.pendingHighlightColor;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (color == null || bookId == null || chapterId == null) return;
    final ids = state.selectedVerseIds;
    await _annotations.setBookmarks(
      state.activeBibleAbbr,
      ids,
      bookId,
      chapterId,
      colorHex: color,
    );
    emit(state.copyWith(
      bookmarks: withBookmarks(state.bookmarks, ids, color),
      selectedVerseIds: const {},
      pendingHighlightColor: null,
    ));
  }

  Future<void> confirmBookmarkOnly() => _applyHighlight();

  Future<NotesRequest?> confirmBookmarkWithNotes() async {
    final selected = _selectedVersesSorted;
    if (selected.isEmpty || state.pendingHighlightColor == null) return null;
    final request = _buildNotesRequest(selected.first);
    await _applyHighlight();
    return request;
  }

  Future<void> refreshNotedVerses() async {
    final chapterId = state.activeChapter?.id;
    if (chapterId == null) return;
    final noted = await _annotations.getNotedVerseIds(
      state.activeBibleAbbr,
      chapterId,
    );
    emit(state.copyWith(notedVerseIds: noted));
  }
}
