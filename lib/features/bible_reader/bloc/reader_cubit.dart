// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../common/utils/app_util.dart';
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../data/models/bible/bible_book.dart';
import '../../../data/models/bible/bible_chapter.dart';
import '../../../data/models/bible/bible_history.dart';
import '../../../data/models/bible/bible_version.dart';
import '../../../domain/entities/bible/verse_display.dart';
import '../../../domain/repos/bible/bible_annotation_repo.dart';
import '../../../domain/repos/bible/bible_repo.dart';
import '../../../domain/repos/bible/bible_tracking_repo.dart';
import '../../../domain/repos/pref_repo.dart';

const _unset = Object();
const readerDefaultFontSize = 18;
const readerMinFontSize = 12;
const readerMaxFontSize = 40;

/// A place to open in the reader — returned by the Search, History and
/// Bookmarks/Notes screens (Android passes the same values as reader route
/// arguments). [verseId] and [searchQuery] are optional.
class ReaderTarget {
  final String bibleAbbr;
  final String bookId;
  final String chapterId;
  final String verseId;
  final String searchQuery;

  const ReaderTarget({
    required this.bibleAbbr,
    required this.bookId,
    required this.chapterId,
    this.verseId = '',
    this.searchQuery = '',
  });
}

/// Where to scroll after a chapter loads (a verse, optionally with a
/// search term to highlight). Ported from Android's `ScrollTarget`.
class ScrollTarget {
  final String verseId;
  final String? highlightQuery;
  const ScrollTarget(this.verseId, {this.highlightQuery});
}

/// Highlight palette offered when bookmarking a selection — same six
/// colors as Android's `AnnotationController.HIGHLIGHT_COLORS`.
const readerHighlightColors = [
  '#FFF59D', // yellow
  '#A5D6A7', // green
  '#90CAF9', // blue
  '#F48FB1', // pink
  '#FFCC80', // orange
  '#CE93D8', // purple
];

/// Everything the note editor needs to open for one verse. Ported from
/// Android's `NotesNavRequest`.
class NotesRequest {
  final String bibleAbbr;
  final String verseId;
  final String bookId;
  final String chapterId;
  final String title;
  final String verseText;

  const NotesRequest({
    required this.bibleAbbr,
    required this.verseId,
    required this.bookId,
    required this.chapterId,
    required this.title,
    required this.verseText,
  });
}

/// Ported from Android's `ReaderUiState`, minus the parts that belong to
/// features not yet ported (scripture queue / download progress).
class ReaderState {
  final bool isLoading;
  final String? error;
  final List<BibleVersion> savedBibles;
  final String activeBible;
  final String activeBibleAbbr;
  final List<BibleBook> books;
  final BibleBook? activeBook;
  final List<BibleChapter> chapters;
  final BibleChapter? activeChapter;
  final List<VerseDisplay> verses;
  final Map<String, List<VerseDisplay>> parallelVerses;
  final int fontSize;
  final bool multiBibleReaderEnabled;
  final String? restoreVerseId;
  final String? highlightQuery;

  /// verseId -> colorHex (null = quick bookmark).
  final Map<String, String?> bookmarks;
  final Set<String> notedVerseIds;

  /// Multi-select: verses picked for bookmark/highlight/notes/copy.
  final Set<String> selectedVerseIds;

  /// Highlight color chosen in the picker, awaiting the
  /// "bookmark only / with notes" confirmation.
  final String? pendingHighlightColor;

  const ReaderState({
    this.isLoading = true,
    this.error,
    this.savedBibles = const [],
    this.activeBible = '',
    this.activeBibleAbbr = '',
    this.books = const [],
    this.activeBook,
    this.chapters = const [],
    this.activeChapter,
    this.verses = const [],
    this.parallelVerses = const {},
    this.fontSize = readerDefaultFontSize,
    this.multiBibleReaderEnabled = true,
    this.restoreVerseId,
    this.highlightQuery,
    this.bookmarks = const {},
    this.notedVerseIds = const {},
    this.selectedVerseIds = const {},
    this.pendingHighlightColor,
  });

  bool get isSelectionMode => selectedVerseIds.isNotEmpty;

  String? get activeBibleLanguage {
    for (final b in savedBibles) {
      if (b.abbreviation == activeBibleAbbr) return b.languageName;
    }
    return null;
  }

  /// Right-to-left script of the active Bible (Arabic, Hebrew, ...).
  bool get isRtl {
    for (final b in savedBibles) {
      if (b.abbreviation == activeBibleAbbr) {
        return b.scriptDirection.toUpperCase() == 'RTL';
      }
    }
    return false;
  }

  ReaderState copyWith({
    bool? isLoading,
    Object? error = _unset,
    List<BibleVersion>? savedBibles,
    String? activeBible,
    String? activeBibleAbbr,
    List<BibleBook>? books,
    Object? activeBook = _unset,
    List<BibleChapter>? chapters,
    Object? activeChapter = _unset,
    List<VerseDisplay>? verses,
    Map<String, List<VerseDisplay>>? parallelVerses,
    int? fontSize,
    bool? multiBibleReaderEnabled,
    Object? restoreVerseId = _unset,
    Object? highlightQuery = _unset,
    Map<String, String?>? bookmarks,
    Set<String>? notedVerseIds,
    Set<String>? selectedVerseIds,
    Object? pendingHighlightColor = _unset,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      savedBibles: savedBibles ?? this.savedBibles,
      activeBible: activeBible ?? this.activeBible,
      activeBibleAbbr: activeBibleAbbr ?? this.activeBibleAbbr,
      books: books ?? this.books,
      activeBook: identical(activeBook, _unset)
          ? this.activeBook
          : activeBook as BibleBook?,
      chapters: chapters ?? this.chapters,
      activeChapter: identical(activeChapter, _unset)
          ? this.activeChapter
          : activeChapter as BibleChapter?,
      verses: verses ?? this.verses,
      parallelVerses: parallelVerses ?? this.parallelVerses,
      fontSize: fontSize ?? this.fontSize,
      multiBibleReaderEnabled:
          multiBibleReaderEnabled ?? this.multiBibleReaderEnabled,
      restoreVerseId: identical(restoreVerseId, _unset)
          ? this.restoreVerseId
          : restoreVerseId as String?,
      highlightQuery: identical(highlightQuery, _unset)
          ? this.highlightQuery
          : highlightQuery as String?,
      bookmarks: bookmarks ?? this.bookmarks,
      notedVerseIds: notedVerseIds ?? this.notedVerseIds,
      selectedVerseIds: selectedVerseIds ?? this.selectedVerseIds,
      pendingHighlightColor: identical(pendingHighlightColor, _unset)
          ? this.pendingHighlightColor
          : pendingHighlightColor as String?,
    );
  }
}

class ReaderCubit extends Cubit<ReaderState> {
  ReaderCubit() : super(const ReaderState());

  final _bibleRepo = getIt<BibleRepo>();
  final _tracking = getIt<BibleTrackingRepo>();
  final _annotations = getIt<BibleAnnotationRepo>();
  final _prefs = getIt<PrefRepo>();

  bool _isFirstLoad = false;

  String get _lastBookId =>
      _prefs.getPrefString(PrefConstants.bibleLastBookIdKey);
  String get _lastChapterId =>
      _prefs.getPrefString(PrefConstants.bibleLastChapterIdKey);
  String get _lastVerseId =>
      _prefs.getPrefString(PrefConstants.bibleLastVerseIdKey);

  bool get _multiBibleEnabled => _prefs.getPrefBool(
        PrefConstants.bibleMultiBibleEnabledKey,
        defaultValue: true,
      );

  List<String> _secondaryList() {
    final csv = _prefs.getPrefString(PrefConstants.bibleSecondaryKey);
    return csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();
  }

  /// Opens the reader. Empty arguments resume from the last-read position
  /// (Android's `ReaderViewModel.initialize`).
  Future<void> initialize({
    String initialBibleAbbr = '',
    String initialBookId = '',
    String initialChapterId = '',
    String initialVerseId = '',
    String initialSearchQry = '',
    bool resumePosition = true,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final bibles = await _bibleRepo.getBibles();
      if (bibles.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No Bibles downloaded yet.'));
        return;
      }

      final lastAbbr = _prefs.getPrefString(PrefConstants.bibleLastBibleAbbrKey);
      final abbr = initialBibleAbbr.isNotEmpty
          ? initialBibleAbbr
          : (lastAbbr.isNotEmpty ? lastAbbr : bibles.first.abbreviation);
      final name = bibles
          .firstWhere(
            (b) => b.abbreviation == abbr,
            orElse: () => bibles.first,
          )
          .name;

      // Opening an explicit target must not fall back to the saved
      // last-read verse, so restore is only for a plain (re)open.
      _isFirstLoad = resumePosition;
      final storedSize = _prefs.getPrefInt(PrefConstants.bibleFontSizeKey);

      emit(state.copyWith(
        savedBibles: bibles,
        activeBible: name,
        activeBibleAbbr: abbr,
        fontSize: storedSize > 0 ? storedSize : readerDefaultFontSize,
        multiBibleReaderEnabled: _multiBibleEnabled,
      ));

      await _loadBooks(
        abbr,
        initialBookId,
        initialChapterId,
        forceScrollToFirstVerse: !resumePosition && initialVerseId.isEmpty,
        scrollTarget: initialVerseId.isNotEmpty
            ? ScrollTarget(
                initialVerseId,
                highlightQuery: initialSearchQry.isEmpty ? null : initialSearchQry,
              )
            : null,
      );
    } catch (e) {
      logger('Reader initialize error: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadBooks(
    String abbr,
    String bookId,
    String chapterId, {
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final books = await _bibleRepo.getLocalBooks(abbr);
    if (books.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error:
            'Bible data not available. Please wait for the download to complete.',
      ));
      return;
    }

    // No explicit book requested: resume where the user left off.
    final resolvedBookId = bookId.isEmpty ? _lastBookId : bookId;
    final resolvedChapterId = chapterId.isEmpty ? _lastChapterId : chapterId;

    final targetBook = books.firstWhere(
      (b) => b.id == resolvedBookId,
      orElse: () => books.first,
    );
    emit(state.copyWith(books: books, activeBook: targetBook));

    await _loadChapters(
      abbr,
      targetBook,
      resolvedChapterId,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
      scrollTarget: scrollTarget,
    );
  }

  Future<void> _loadChapters(
    String abbr,
    BibleBook book,
    String chapterId, {
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final chapters = await _bibleRepo.getLocalChapters(abbr, book.id);
    if (chapters.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No chapters found for ${book.name}',
      ));
      return;
    }
    final target = chapters.firstWhere(
      (c) => c.id == chapterId,
      orElse: () => chapters.first,
    );
    emit(state.copyWith(chapters: chapters, activeChapter: target));

    await _loadVerses(
      abbr,
      target,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
    );
  }

  Future<Map<String, List<VerseDisplay>>> _loadParallel(
    String primaryAbbr,
    String chapterId,
  ) async {
    if (!_multiBibleEnabled) return {};
    final downloaded = state.savedBibles
        .where((b) => b.isDownloaded)
        .map((b) => b.abbreviation)
        .toSet();

    var ordered = _secondaryList()
        .where((a) => a != primaryAbbr && downloaded.contains(a))
        .toList();
    if (ordered.isEmpty) {
      ordered = state.savedBibles
          .where((b) => b.abbreviation != primaryAbbr && b.isDownloaded)
          .map((b) => b.abbreviation)
          .toList();
    }

    final map = <String, List<VerseDisplay>>{};
    for (final s in ordered) {
      final verses = await _bibleRepo.getLocalVerses(s, chapterId);
      if (verses != null) map[s] = verses;
    }
    return map;
  }

  ScrollTarget? _resolveScrollTarget(
    ScrollTarget? explicit,
    bool forceFirst,
    List<VerseDisplay> verses,
  ) {
    ScrollTarget? resolved;
    if (explicit != null) {
      resolved = explicit;
    } else if (forceFirst) {
      resolved = verses.isEmpty ? null : ScrollTarget(verses.first.verseId);
    } else if (_isFirstLoad && _lastVerseId.isNotEmpty) {
      resolved = ScrollTarget(_lastVerseId);
    }
    _isFirstLoad = false;
    return resolved;
  }

  Future<void> _loadVerses(
    String abbr,
    BibleChapter chapter, {
    ScrollTarget? scrollTarget,
    bool forceScrollToFirstVerse = false,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    final verses = await _bibleRepo.getLocalVerses(abbr, chapter.id);
    if (verses == null) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Verses not cached. Please ensure download is complete.',
      ));
      return;
    }

    final parallel = await _loadParallel(abbr, chapter.id);
    final bookmarks = await _annotations.getBookmarksForChapter(abbr, chapter.id);
    final noted = await _annotations.getNotedVerseIds(abbr, chapter.id);
    final target =
        _resolveScrollTarget(scrollTarget, forceScrollToFirstVerse, verses);

    emit(state.copyWith(
      isLoading: false,
      verses: verses,
      parallelVerses: parallel,
      activeChapter: chapter,
      activeBibleAbbr: abbr,
      bookmarks: bookmarks,
      notedVerseIds: noted,
      selectedVerseIds: const {},
      pendingHighlightColor: null,
      multiBibleReaderEnabled: _multiBibleEnabled,
      restoreVerseId: target?.verseId,
      highlightQuery: target?.highlightQuery,
    ));

    await _recordVersesLoaded(abbr, chapter, verses);
  }

  Future<void> _recordVersesLoaded(
    String abbr,
    BibleChapter chapter,
    List<VerseDisplay> verses,
  ) async {
    _prefs.setPrefString(PrefConstants.bibleLastBibleAbbrKey, abbr);
    _prefs.setPrefString(PrefConstants.bibleLastBookIdKey, chapter.bookId);
    _prefs.setPrefString(PrefConstants.bibleLastChapterIdKey, chapter.id);

    final book = state.activeBook;
    if (book == null) return;
    await _tracking.recordReading(
      BibleHistory(
        bibleAbbr: abbr,
        bibleName: state.activeBible,
        bookId: book.id,
        bookName: book.name,
        chapterId: chapter.id,
        chapterRef: chapter.reference,
        verseNumber: verses.isEmpty ? 1 : verses.first.number,
        readAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Called by the view (debounced) as the visible verse changes.
  Future<void> onVerseScrollPositionChanged(
    String verseId,
    int verseNumber,
  ) async {
    final chapter = state.activeChapter;
    final book = state.activeBook;
    if (chapter == null || book == null) return;
    _prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, verseId);
    await _tracking.recordReading(
      BibleHistory(
        bibleAbbr: state.activeBibleAbbr,
        bibleName: state.activeBible,
        bookId: book.id,
        bookName: book.name,
        chapterId: chapter.id,
        chapterRef: chapter.reference,
        verseNumber: verseNumber,
        readAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Opens a place picked from Search / History / Bookmarks & Notes.
  Future<void> openTarget(ReaderTarget target) {
    return initialize(
      initialBibleAbbr: target.bibleAbbr,
      initialBookId: target.bookId,
      initialChapterId: target.chapterId,
      initialVerseId: target.verseId,
      initialSearchQry: target.searchQuery,
      resumePosition: false,
    );
  }

  void consumeRestoreVerseTarget() =>
      emit(state.copyWith(restoreVerseId: null));

  void navigateChapter(int direction) {
    final current = state.activeChapter;
    if (current == null) return;
    final idx = state.chapters.indexWhere((c) => c.id == current.id);
    final nextIdx = idx + direction;
    if (idx < 0 || nextIdx < 0 || nextIdx >= state.chapters.length) return;
    selectChapter(state.chapters[nextIdx]);
  }

  Future<void> selectChapter(BibleChapter chapter, {ScrollTarget? scrollTarget}) {
    return _loadVerses(
      state.activeBibleAbbr,
      chapter,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: scrollTarget == null,
    );
  }

  Future<void> selectBook(BibleBook book) async {
    emit(state.copyWith(
      activeBook: book,
      chapters: const [],
      verses: const [],
    ));
    await _loadChapters(
      state.activeBibleAbbr,
      book,
      '',
      forceScrollToFirstVerse: true,
    );
  }

  Future<void> setPrimaryBible(String abbr) async {
    final chapter = state.activeChapter;
    if (chapter == null) return;
    final name = state.savedBibles
        .firstWhere(
          (b) => b.abbreviation == abbr,
          orElse: () => state.savedBibles.first,
        )
        .name;

    _prefs.setPrefString(PrefConstants.biblePrimaryKey, abbr);
    _prefs.setPrefString(PrefConstants.bibleLastBibleKey, name);
    _prefs.setPrefString(
      PrefConstants.bibleSecondaryKey,
      _secondaryList().where((a) => a != abbr).join(','),
    );
    emit(state.copyWith(activeBible: name, activeBibleAbbr: abbr));

    await _loadVerses(abbr, chapter);
    await _loadBooks(abbr, state.activeBook?.id ?? '', chapter.id);
  }

  Future<void> setMultiBibleReaderEnabled(bool enabled) async {
    _prefs.setPrefBool(PrefConstants.bibleMultiBibleEnabledKey, enabled);
    emit(state.copyWith(multiBibleReaderEnabled: enabled));
    final chapter = state.activeChapter;
    if (chapter != null) await _loadVerses(state.activeBibleAbbr, chapter);
  }

  void setFontSize(int size) {
    final clamped = size.clamp(readerMinFontSize, readerMaxFontSize);
    _prefs.setPrefInt(PrefConstants.bibleFontSizeKey, clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  /// Swipe/tap action: toggles an uncolored bookmark on one verse.
  Future<void> quickToggleBookmark(String verseId) async {
    final abbr = state.activeBibleAbbr;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (bookId == null || chapterId == null) return;

    if (state.bookmarks.containsKey(verseId)) {
      await _annotations.removeBookmarks(abbr, [verseId]);
      emit(state.copyWith(bookmarks: {...state.bookmarks}..remove(verseId)));
    } else {
      await _annotations.setBookmarks(abbr, [verseId], bookId, chapterId);
      emit(state.copyWith(bookmarks: {...state.bookmarks, verseId: null}));
    }
  }

  // ---- Multi-select, highlight colors, notes, copy (AnnotationController) ----

  void toggleVerseSelected(String verseId) {
    final next = {...state.selectedVerseIds};
    if (!next.remove(verseId)) next.add(verseId);
    emit(state.copyWith(selectedVerseIds: next));
  }

  void clearSelection() => emit(state.copyWith(
        selectedVerseIds: const {},
        pendingHighlightColor: null,
      ));

  void chooseHighlightColor(String colorHex) =>
      emit(state.copyWith(pendingHighlightColor: colorHex));

  void cancelPendingHighlight() =>
      emit(state.copyWith(pendingHighlightColor: null));

  List<VerseDisplay> get _selectedVersesSorted => state.verses
      .where((v) => state.selectedVerseIds.contains(v.verseId))
      .toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  NotesRequest _buildNotesRequest(VerseDisplay verse) {
    final bookName = state.activeBook?.name ?? verse.bookId;
    final chapterNumber = state.activeChapter?.number ?? '';
    return NotesRequest(
      bibleAbbr: state.activeBibleAbbr,
      verseId: verse.verseId,
      bookId: state.activeBook?.id ?? verse.bookId,
      chapterId: state.activeChapter?.id ?? verse.chapterId,
      title: '$bookName $chapterNumber:${verse.number}',
      verseText: verse.text,
    );
  }

  /// Notes request for a single verse (hover "note" button).
  NotesRequest? notesRequestForVerse(String verseId) {
    for (final v in state.verses) {
      if (v.verseId == verseId) return _buildNotesRequest(v);
    }
    return null;
  }

  /// Notes for the selection — only when exactly one verse is selected.
  /// Clears the selection, like Android's `openNotesForSelection`.
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
      bookmarks: {...state.bookmarks, for (final id in ids) id: color},
      selectedVerseIds: const {},
      pendingHighlightColor: null,
    ));
  }

  Future<void> confirmBookmarkOnly() => _applyHighlight();

  /// Bookmarks the selection with the chosen color, then returns a notes
  /// request for the first selected verse (lowest verse number).
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

  /// Formatted text for the selected verses — used by Copy.
  String? buildSelectionShareText() {
    final selected = _selectedVersesSorted;
    if (selected.isEmpty) return null;
    final reference =
        '${_referencePrefix()}${_formatVerseRange(selected.map((v) => v.number).toList())}';
    final body = selected.map((v) => '${v.number} ${v.text}').join('\n');
    return _shareText(reference, body);
  }

  /// Formatted text for the whole active chapter.
  String? buildActiveChapterShareText() {
    if (state.verses.isEmpty) return null;
    final reference = _referencePrefix().replaceAll(RegExp(r'[: ]+$'), '');
    final sorted = [...state.verses]..sort((a, b) => a.number.compareTo(b.number));
    return _shareText(reference, sorted.map((v) => '${v.number} ${v.text}').join('\n'));
  }

  String _referencePrefix() {
    final bookName =
        state.activeBook?.name ?? (state.verses.isEmpty ? '' : state.verses.first.bookId);
    final chapterNumber = state.activeChapter?.number;
    return (chapterNumber == null || chapterNumber.trim().isEmpty)
        ? '$bookName '
        : '$bookName $chapterNumber:';
  }

  String _shareText(String reference, String body) {
    final language = state.activeBibleLanguage;
    final footnote = language == null || language.trim().isEmpty
        ? state.activeBible
        : '${state.activeBible} ($language)';
    return '$reference\n\n$body\n\n— $footnote';
  }

  /// Collapses verse numbers into a compact range, e.g. [16,17,18,20] ->
  /// "16-18, 20".
  String _formatVerseRange(List<int> numbers) {
    if (numbers.isEmpty) return '';
    final sorted = [...numbers]..sort();
    final parts = <String>[];
    var start = sorted.first;
    var prev = sorted.first;
    for (final n in sorted.skip(1)) {
      if (n == prev + 1) {
        prev = n;
        continue;
      }
      parts.add(start == prev ? '$start' : '$start-$prev');
      start = n;
      prev = n;
    }
    parts.add(start == prev ? '$start' : '$start-$prev');
    return parts.join(', ');
  }
}
