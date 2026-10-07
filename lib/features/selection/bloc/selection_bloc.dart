// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../common/utils/app_util.dart';
import '../../../common/utils/constants/pref_constants.dart';
import '../../../common/utils/network_utils.dart';
import '../../../core/di/injectable.dart';
import '../../../data/models/song/song.dart';
import '../../../data/models/song/songbook.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../../../domain/repos/bible/bible_selection_repo.dart';
import '../../../domain/repos/database_repo.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../../domain/repos/song/song_selection_repo.dart';

part 'selection_event.dart';
part 'selection_state.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  SelectionBloc({this.only}) : super(_initial(getIt<PrefRepo>(), only)) {
    on<SelectionStarted>(_onStarted);
    on<ModulesToggled>(_onModulesToggled);
    on<ModulesChosen>(_onModulesChosen);
    on<SelectionBackPressed>(_onBack);
    on<BooksRequested>(_onBooksRequested);
    on<BookToggled>(_onBookToggled);
    on<BooksConfirmed>(_onBooksConfirmed);
    on<SongsDownloadRetried>((_, emit) => _runSave(emit, finish: _finishAfterSave));
    on<BiblesRequested>(_onBiblesRequested);
    on<BibleToggled>(_onBibleToggled);
    on<BiblesConfirmed>(_onBiblesConfirmed);
    on<BibleDownloadResumed>(_onBibleResumed);
    on<BibleDownloadRestarted>(_onBibleRestarted);
  }

  final SelectionStepType? only;

  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();
  final _songRepo = SongSelectionRepo();
  final _bibleRepo = BibleSelectionRepo();

  static SelectionState _initial(PrefRepo prefs, SelectionStepType? only) {
    if (only != null) return SelectionState(steps: [only]);

    final chosen = prefs.keyExists(PrefConstants.songlibModuleEnabledKey) ||
        prefs.keyExists(PrefConstants.biblelibModuleEnabledKey);
    if (!chosen) {
      return const SelectionState(steps: [SelectionStepType.modules]);
    }

    final songlib = prefs.getPrefBool(PrefConstants.songlibModuleEnabledKey);
    final biblelib = prefs.getPrefBool(PrefConstants.biblelibModuleEnabledKey);
    final songSelected = prefs.getPrefBool(PrefConstants.dataIsSelectedKey);
    final songLoaded = prefs.getPrefBool(PrefConstants.dataIsLoadedKey);
    final bibleLoaded = prefs.getPrefBool(PrefConstants.biblelibDataLoadedKey);

    return SelectionState(
      songlib: songlib,
      biblelib: biblelib,
      steps: [
        if (songlib && !songSelected && !songLoaded)
          SelectionStepType.songs,
        if (biblelib && !bibleLoaded) SelectionStepType.bibles,
      ],
    );
  }

  bool _finishAfterSave = true;
  bool _booksPersisted = false;

  Future<void> _onStarted(
    SelectionStarted event,
    Emitter<SelectionState> emit,
  ) async {
    final resume = only == null &&
        _prefRepo.getPrefBool(PrefConstants.songlibModuleEnabledKey) &&
        _prefRepo.getPrefBool(PrefConstants.dataIsSelectedKey) &&
        !_prefRepo.getPrefBool(PrefConstants.dataIsLoadedKey);
    if (!resume) return;
    _booksPersisted = true;
    _finishAfterSave = state.steps.isEmpty;
    emit(state.copyWith(planSongs: true, planBible: false));
    await _runSave(emit, finish: _finishAfterSave);
  }

  void _onModulesToggled(ModulesToggled event, Emitter<SelectionState> emit) {
    emit(
      state.copyWith(
        songlib: event.songlib ?? state.songlib,
        biblelib: event.biblelib ?? state.biblelib,
      ),
    );
  }

  void _onModulesChosen(ModulesChosen event, Emitter<SelectionState> emit) {
    _prefRepo.setPrefBool(
      PrefConstants.songlibModuleEnabledKey,
      event.songlib,
    );
    _prefRepo.setPrefBool(
      PrefConstants.biblelibModuleEnabledKey,
      event.biblelib,
    );
    emit(
      state.copyWith(
        songlib: event.songlib,
        biblelib: event.biblelib,
        index: 1,
        steps: [
          SelectionStepType.modules,
          if (event.songlib) SelectionStepType.songs,
          if (event.biblelib) SelectionStepType.bibles,
        ],
      ),
    );
  }

  void _onBack(SelectionBackPressed event, Emitter<SelectionState> emit) {
    if (state.canGoBack) emit(state.copyWith(index: state.index - 1));
  }

  Future<void> _next(Emitter<SelectionState> emit) async {
    if (state.index + 1 < state.steps.length) {
      emit(state.copyWith(index: state.index + 1));
      return;
    }
    _finishAfterSave = true;
    emit(
      state.copyWith(
        planSongs: state.steps.contains(SelectionStepType.songs),
        planBible: state.steps.contains(SelectionStepType.bibles),
      ),
    );
    await _runSave(emit, finish: true);
  }

  Future<void> _runSave(
    Emitter<SelectionState> emit, {
    required bool finish,
    _BibleRun? bibleRun,
  }) async {
    emit(state.copyWith(saveActive: true));

    if (state.planSongs && state.songsPhase != SongsPhase.done) {
      if (!await _saveSongs(emit)) return;
    }
    if (state.planBible && state.bibleStatus != BibleStatus.saved) {
      if (!await _saveBible(emit, bibleRun ?? _confirmedBibleRun)) return;
    }

    if (finish) {
      emit(state.copyWith(finishing: true));
    } else {
      emit(state.copyWith(saveActive: false));
    }
  }

  Set<int> _savedBookIds() => _prefRepo
      .getPrefString(PrefConstants.selectedBooksKey)
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toSet();

  Future<void> _onBooksRequested(
    BooksRequested event,
    Emitter<SelectionState> emit,
  ) async {
    emit(state.copyWith(booksStatus: LoadStatus.loading));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(booksStatus: LoadStatus.noInternet));
      return;
    }
    try {
      final books = await _songRepo.fetchBooks();

      final saved = state.selectedBookIds.isNotEmpty
          ? state.selectedBookIds
          : _savedBookIds();
      emit(
        state.copyWith(
          booksStatus: LoadStatus.loaded,
          books: books,
          selectedBookIds: {
            for (final b in books)
              if (b.bookId != null && saved.contains(b.bookId)) b.bookId!,
          }.take(maxSongbookSelections).toSet(),
        ),
      );
    } on SongApiException catch (e) {
      logger('Books request failed: $e');
      emit(
        state.copyWith(
          booksStatus: LoadStatus.failure,
          booksError: e.statusCode.toString(),
        ),
      );
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(booksStatus: LoadStatus.failure, booksError: '100'));
    }
  }

  void _onBookToggled(BookToggled event, Emitter<SelectionState> emit) {
    final selected = {...state.selectedBookIds};
    if (!selected.remove(event.bookId)) {
      if (selected.length >= maxSongbookSelections) return;
      selected.add(event.bookId);
    }
    emit(state.copyWith(selectedBookIds: selected));
  }

  Future<void> _onBooksConfirmed(
    BooksConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    if (state.selectedBookIds.isEmpty) return;
    await _next(emit);
  }

  Future<void> _persistBooks() async {
    final selected = state.selectedBooks;
    final newIds = {for (final b in selected) b.bookId!};

    for (final existing in await _dbRepo.fetchBooks()) {
      final id = existing.bookId;
      if (id != null && !newIds.contains(id)) {
        await _dbRepo.removeSongsByBook(id);
        await _dbRepo.removeBookByBookId(id);
      }
    }
    for (final book in selected) {
      await _dbRepo.removeBookByBookId(book.bookId!);
      await _dbRepo.saveBook(book);
    }

    _prefRepo.setPrefString(PrefConstants.selectedBooksKey, newIds.join(','));
    _prefRepo.setPrefBool(PrefConstants.dataIsSelectedKey, true);
    _prefRepo.setPrefBool(PrefConstants.dataIsLoadedKey, false);
    _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, true);
  }

  Future<bool> _saveSongs(Emitter<SelectionState> emit) async {
    emit(state.copyWith(songsPhase: SongsPhase.fetching, songsProgress: 0));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(songsPhase: SongsPhase.noInternet));
      return false;
    }

    if (!_booksPersisted) {
      try {
        await _persistBooks();
        _booksPersisted = true;
      } catch (e) {
        logger('Unable to save books: $e');
        emit(state.copyWith(songsPhase: SongsPhase.failed, songsError: '100'));
        return false;
      }
    }

    final selectedBooks = _prefRepo.getPrefString(
      PrefConstants.selectedBooksKey,
    );
    final List<Song> songs;
    try {
      songs = await _songRepo.fetchSongsByBooks(selectedBooks);
    } on SongApiException catch (e) {
      logger('Songs request failed: $e');
      emit(
        state.copyWith(
          songsPhase: SongsPhase.failed,
          songsError: e.statusCode.toString(),
        ),
      );
      return false;
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(songsPhase: SongsPhase.failed, songsError: '100'));
      return false;
    }

    if (songs.isNotEmpty) {
      for (final id in _savedBookIds()) {
        await _dbRepo.removeSongsByBook(id);
      }

      var index = 0;
      for (final song in songs) {
        try {
          final progress = ((index / songs.length) * 100).toInt();
          emit(
            state.copyWith(
              songsPhase: SongsPhase.saving,
              songsProgress: progress,
              songsFeedback: _songsFeedback(progress),
            ),
          );
          await _dbRepo.saveSong(song);
          index++;
        } catch (e) {
          logger('Unable to save song ${song.songId}: $e');
        }
      }
      _prefRepo.setPrefBool(PrefConstants.dataIsLoadedKey, true);
      _prefRepo.setPrefBool(PrefConstants.wakeLockCheckKey, true);
    }

    emit(state.copyWith(songsPhase: SongsPhase.done));
    return true;
  }

  String _songsFeedback(int progress) => switch (progress) {
        1 => 'On your\nmarks ...',
        5 => 'Set. \nReady ...',
        10 => 'Loading\nsongs ...',
        20 => 'Patience\npays ...',
        40 => 'Loading\nsongs ...',
        75 => 'Thanks for\nyour patience!',
        85 => 'Finishing up',
        95 => "We're almost done",
        _ => state.songsFeedback,
      };

  List<BibleInfoDto> get _selectedDtos => [
        for (final abbr in state.selectedAbbrs)
          ...state.availableBibles.where((b) => b.abbreviation == abbr),
      ];

  Future<void> _onBiblesRequested(
    BiblesRequested event,
    Emitter<SelectionState> emit,
  ) async {
    emit(state.copyWith(bibleStatus: BibleStatus.loading));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(
        state.copyWith(
          bibleStatus: BibleStatus.error,
          bibleMessage: 'No internet connection. Connect and try again.',
        ),
      );
      return;
    }
    try {
      final available = await _bibleRepo.fetchAvailable();
      final known = available.map((b) => b.abbreviation).toSet();
      emit(
        state.copyWith(
          bibleStatus: BibleStatus.loaded,
          availableBibles: available,
          selectedAbbrs: _bibleRepo.selectedAbbrs
              .where(known.contains)
              .take(maxBibleSelections)
              .toList(),
          maxSelections: maxBibleSelections,
        ),
      );
    } catch (e) {
      logger('BibleSelection fetch failed: $e');
      emit(
        state.copyWith(
          bibleStatus: BibleStatus.error,
          bibleMessage:
              'Could not load Bibles. Please check your connection and try again.',
        ),
      );
    }
  }

  void _onBibleToggled(BibleToggled event, Emitter<SelectionState> emit) {
    final selected = [...state.selectedAbbrs];
    if (selected.contains(event.abbr)) {
      selected.remove(event.abbr);
    } else {
      if (selected.length >= state.maxSelections) return;
      selected.add(event.abbr);
    }
    emit(state.copyWith(selectedAbbrs: selected));
  }

  _BibleRun get _confirmedBibleRun => _BibleRun(
        startStep: 'Preparing...',
        beforeDownload: () => _bibleRepo.persistSelection(_selectedDtos),
        failMessage:
            'Failed to download the Bible. You can continue where it left off or restart.',
      );

  Future<bool> _saveBible(Emitter<SelectionState> emit, _BibleRun run) async {
    emit(
      state.copyWith(
        bibleStatus: BibleStatus.saving,
        bibleStep: run.startStep,
        bibleProgress: run.startProgress,
      ),
    );
    var lastProgress = run.startProgress;
    try {
      if (run.beforeDownload != null) await run.beforeDownload!();
      await _bibleRepo.downloadPrimaryAndQueueSecondaries(
        _selectedDtos,
        onProgress: (step, progress) async {
          lastProgress = progress;
          if (!isClosed) {
            emit(state.copyWith(bibleStep: step, bibleProgress: progress));
          }
        },
      );
      emit(
        state.copyWith(bibleStatus: BibleStatus.saved, bibleProgress: 1),
      );
      return true;
    } catch (e) {
      logger('BibleSelection download failed: $e');
      emit(
        state.copyWith(
          bibleStatus: BibleStatus.saveFailed,
          bibleMessage: run.failMessage,
          bibleProgress: lastProgress,
        ),
      );
      return false;
    }
  }

  Future<void> _onBiblesConfirmed(
    BiblesConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    await _next(emit);
  }

  Future<void> _onBibleResumed(
    BibleDownloadResumed event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    final primary = state.selectedAbbrs.first;
    await _runSave(
      emit,
      finish: _finishAfterSave,
      bibleRun: _BibleRun(
        startStep: 'Resuming download...',
        startProgress: await _bibleRepo.savedProgress(primary),
        failMessage:
            "Still couldn't finish the download. You can continue or restart.",
      ),
    );
  }

  Future<void> _onBibleRestarted(
    BibleDownloadRestarted event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    final primary = state.selectedAbbrs.first;
    await _runSave(
      emit,
      finish: _finishAfterSave,
      bibleRun: _BibleRun(
        startStep: 'Restarting download...',
        beforeDownload: () => _bibleRepo.restart(primary),
        failMessage:
            'Failed to download the Bible. You can continue where it left off or restart.',
      ),
    );
  }
}

class _BibleRun {
  const _BibleRun({
    required this.startStep,
    this.startProgress = 0,
    this.beforeDownload,
    required this.failMessage,
  });

  final String startStep;
  final double startProgress;
  final Future<void> Function()? beforeDownload;
  final String failMessage;
}