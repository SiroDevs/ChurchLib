// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/reader_utils.dart';
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
  BibleReaderCubit() : super(const BibleReaderState());

  final _bibleRepo = getIt<BibleRepo>();
  final _tracking = getIt<BibleTrackingRepo>();
  final _annotations = getIt<BibleAnnotationRepo>();
  final _prefs = getIt<PrefRepo>();

  bool _isFirstLoad = false;

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
    final name =
        firstWhereOrFirst(state.savedBibles, (b) => b.abbreviation == abbr).name;

    saveReaderPrimaryBible(_prefs, abbr: abbr, name: name);
    emit(state.copyWith(activeBible: name, activeBibleAbbr: abbr));

    await _loadVerses(abbr, chapter);
    await _loadBooks(abbr, state.activeBook?.id ?? '', chapter.id);
  }

  Future<void> setMultiBibleReaderEnabled(bool enabled) async {
    saveReaderMultiBibleEnabled(_prefs, enabled);
    emit(state.copyWith(multiBibleReaderEnabled: enabled));
    final chapter = state.activeChapter;
    if (chapter != null) await _loadVerses(state.activeBibleAbbr, chapter);
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
