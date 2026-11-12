// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/reader/bible_settings_signal.dart';
import '../../../../common/utils/reader/reader_utils.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_book.dart';
import '../../../../data/models/bible/bible_chapter.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../domain/entities/bible/verse_display.dart';
import '../../../../domain/repos/bible/bible_annotation_repo.dart';
import '../../../../domain/repos/bible/bible_repo.dart';
import '../../../../domain/repos/bible/bible_tracking_repo.dart';
import '../../../../domain/repos/pref_repo.dart';

part 'bible_reader_state.dart';
part 'reader_loading_mixin.dart';
part 'reader_selection_mixin.dart';
part 'reader_verses_mixin.dart';

const _unset = Object();

class BibleReaderCubit extends Cubit<BibleReaderState>
    with ReaderLoadingMixin, ReaderVersesMixin, ReaderSelectionMixin {
  BibleReaderCubit() : super(const BibleReaderState()) {
    bibleSettingsChanged.addListener(_onBibleSettingsChanged);
  }

  void _onBibleSettingsChanged() => refreshParallel();

  @override
  Future<void> close() {
    bibleSettingsChanged.removeListener(_onBibleSettingsChanged);
    return super.close();
  }

  final _bibleRepo = getIt<BibleRepo>();
  final _tracking = getIt<BibleTrackingRepo>();
  final _annotations = getIt<BibleAnnotationRepo>();
  final _prefs = getIt<PrefRepo>();

  bool _isFirstLoad = false;
  int _loadRequestId = 0;
  int _parallelRequestId = 0;

  int _startLoadRequest() => ++_loadRequestId;

  bool _isCurrentLoadRequest(int requestId) =>
      !isClosed && requestId == _loadRequestId;

  void navigateChapter(int direction) {
    final current = state.activeChapter;
    if (current == null) return;
    final idx = state.chapters.indexWhere((c) => c.id == current.id);
    final nextIdx = idx + direction;
    if (idx < 0 || nextIdx < 0 || nextIdx >= state.chapters.length) return;
    selectChapter(state.chapters[nextIdx]);
  }

  Future<void> selectChapter(
    BibleChapter chapter, {
    ScrollTarget? scrollTarget,
  }) {
    final requestId = _startLoadRequest();
    return _loadVerses(
      state.activeBibleAbbr,
      chapter,
      requestId: requestId,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: scrollTarget == null,
    );
  }

  Future<void> selectBook(BibleBook book) async {
    final requestId = _startLoadRequest();
    emit(
      state.copyWith(
        activeBook: book,
        activeChapter: null,
        chapters: const [],
        verses: const [],
        parallelVerses: const {},
        isLoading: true,
        error: null,
      ),
    );
    await _loadChapters(
      state.activeBibleAbbr,
      book,
      '',
      requestId: requestId,
      forceScrollToFirstVerse: true,
    );
  }

  Future<void> setPrimaryBible(String abbr) async {
    final chapter = state.activeChapter;
    if (chapter == null) return;
    final requestId = _startLoadRequest();
    final bookId = state.activeBook?.id ?? '';
    final name = firstWhereOrFirst(
      state.savedBibles,
      (b) => b.abbreviation == abbr,
    ).name;

    saveReaderPrimaryBible(_prefs, abbr: abbr, name: name);
    emit(
      state.copyWith(
        activeBible: name,
        activeBibleAbbr: abbr,
        isLoading: true,
        error: null,
      ),
    );
    await _loadBooks(abbr, bookId, chapter.id, requestId: requestId);
  }

  Future<void> setMultiBibleReaderEnabled(bool enabled) async {
    saveReaderMultiBibleEnabled(_prefs, enabled);
    await refreshParallel();
  }

  void setFontSize(int size) {
    final clamped = clampReaderFontSize(size);
    saveReaderFontSize(_prefs, clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  String? buildSelectionShareText() => buildVerseSelectionShareText(
    selected: _selectedVersesSorted,
    chapterVerses: state.verses,
    book: state.activeBook,
    chapter: state.activeChapter,
    bibleName: state.activeBible,
    language: state.activeBibleLanguage,
  );

  String? buildActiveChapterShareText() => buildChapterShareText(
    chapterVerses: state.verses,
    book: state.activeBook,
    chapter: state.activeChapter,
    bibleName: state.activeBible,
    language: state.activeBibleLanguage,
  );
}
