part of 'bible_reader_cubit.dart';

mixin ReaderSelectionMixin on Cubit<BibleReaderState> {
  BibleAnnotationRepo get _annotations;

  bool _isActiveChapter(String abbr, String bookId, String chapterId) =>
      !isClosed &&
      state.activeBibleAbbr == abbr &&
      state.activeBook?.id == bookId &&
      state.activeChapter?.id == chapterId;

  Future<void> quickToggleBookmark(String verseId) async {
    final abbr = state.activeBibleAbbr;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (bookId == null || chapterId == null) return;

    if (state.bookmarks.containsKey(verseId)) {
      await _annotations.removeBookmarks(abbr, [verseId]);
      if (!_isActiveChapter(abbr, bookId, chapterId)) return;
      emit(
        state.copyWith(bookmarks: withoutBookmark(state.bookmarks, verseId)),
      );
    } else {
      await _annotations.setBookmarks(abbr, [verseId], bookId, chapterId);
      if (!_isActiveChapter(abbr, bookId, chapterId)) return;
      emit(
        state.copyWith(
          bookmarks: withBookmarks(state.bookmarks, [verseId], null),
        ),
      );
    }
  }

  void toggleVerseSelected(String verseId) {
    emit(
      state.copyWith(
        selectedVerseIds: toggleVerseSelection(state.selectedVerseIds, verseId),
      ),
    );
  }

  void clearSelection() => emit(
    state.copyWith(selectedVerseIds: const {}, pendingHighlightColor: null),
  );

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

  Future<bool> _applyHighlight() async {
    final color = state.pendingHighlightColor;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    final abbr = state.activeBibleAbbr;
    if (color == null || bookId == null || chapterId == null) return false;
    final ids = {...state.selectedVerseIds};
    await _annotations.setBookmarks(
      abbr,
      ids,
      bookId,
      chapterId,
      colorHex: color,
    );
    if (!_isActiveChapter(abbr, bookId, chapterId) ||
        state.pendingHighlightColor != color ||
        state.selectedVerseIds.length != ids.length ||
        !state.selectedVerseIds.containsAll(ids)) {
      return false;
    }
    emit(
      state.copyWith(
        bookmarks: withBookmarks(state.bookmarks, ids, color),
        selectedVerseIds: const {},
        pendingHighlightColor: null,
      ),
    );
    return true;
  }

  Future<void> confirmBookmarkOnly() async {
    await _applyHighlight();
  }

  Future<NotesRequest?> confirmBookmarkWithNotes() async {
    final selected = _selectedVersesSorted;
    if (selected.isEmpty || state.pendingHighlightColor == null) return null;
    final request = _buildNotesRequest(selected.first);
    return await _applyHighlight() ? request : null;
  }

  Future<void> refreshNotedVerses() async {
    final abbr = state.activeBibleAbbr;
    final chapterId = state.activeChapter?.id;
    if (abbr.isEmpty || chapterId == null) return;
    final noted = await _annotations.getNotedVerseIds(abbr, chapterId);
    if (isClosed ||
        state.activeBibleAbbr != abbr ||
        state.activeChapter?.id != chapterId) {
      return;
    }
    emit(state.copyWith(notedVerseIds: noted));
  }
}
