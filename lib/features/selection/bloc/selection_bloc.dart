// Dart imports:
import 'dart:convert';

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

/// The one bloc behind the Selection screen: the app choice, songbook
/// selection + songs download, and Bible selection + download, plus the
/// step-by-step flow that strings them together.
///
/// Which steps are needed is worked out from the prefs, so the same bloc
/// serves a fresh install, a resumed install, and "add SongLib / BibleLib"
/// or a module reset from Settings. Pass [only] to run a single step
/// (Settings → Bibles → add more uses `SelectionStepType.bibles`).
class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  SelectionBloc({this.only}) : super(_initial(getIt<PrefRepo>(), only)) {
    on<SelectionStarted>(_onStarted);
    on<ModulesChosen>(_onModulesChosen);
    on<SelectionBackPressed>(_onBack);
    on<BooksRequested>(_onBooksRequested);
    on<BookToggled>(_onBookToggled);
    on<BooksConfirmed>(_onBooksConfirmed);
    on<SongsDownloadRetried>((_, emit) => _downloadSongs(emit));
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

  // ── initial state ────────────────────────────────────────────────────────
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
          SelectionStepType.songbooks,
        if (biblelib && !bibleLoaded) SelectionStepType.bibles,
      ],
    );
  }

  // ── flow ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
    SelectionStarted event,
    Emitter<SelectionState> emit,
  ) async {
    // An earlier run chose its songbooks but never finished downloading the
    // songs: pick that up again straight away instead of asking again.
    final resume = only == null &&
        _prefRepo.getPrefBool(PrefConstants.songlibModuleEnabledKey) &&
        _prefRepo.getPrefBool(PrefConstants.dataIsSelectedKey) &&
        !_prefRepo.getPrefBool(PrefConstants.dataIsLoadedKey);
    if (resume) await _downloadSongs(emit);
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
          if (event.songlib) SelectionStepType.songbooks,
          if (event.biblelib) SelectionStepType.bibles,
        ],
      ),
    );
  }

  void _onBack(SelectionBackPressed event, Emitter<SelectionState> emit) {
    if (state.canGoBack) emit(state.copyWith(index: 0));
  }

  /// A download step finished: move on, or finish when it was the last one.
  void _completed(SelectionStepType type, Emitter<SelectionState> emit) {
    if (state.finishing) return;
    if (state.current == type) {
      if (state.index + 1 < state.steps.length) {
        emit(state.copyWith(index: state.index + 1));
      } else {
        emit(state.copyWith(finishing: true));
      }
    } else if (state.steps.isEmpty) {
      // Resumed songs download with no step left to show.
      emit(state.copyWith(finishing: true));
    }
  }

  // ── songbooks ────────────────────────────────────────────────────────────
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
      final resp = await _songRepo.getBooks();
      if (resp.statusCode != 200) {
        emit(
          state.copyWith(
            booksStatus: LoadStatus.failure,
            booksError: resp.statusCode.toString(),
          ),
        );
        return;
      }
      final dataList = List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      final books = dataList.map((item) => SongBook.fromJson(item)).toList();

      // Tick what was chosen on an earlier run.
      final saved = _prefRepo.getPrefString(PrefConstants.selectedBooksKey);
      final savedNos = saved.isEmpty ? <String>{} : saved.split(',').toSet();
      emit(
        state.copyWith(
          booksStatus: LoadStatus.loaded,
          books: books,
          selectedBookNos: {
            for (final b in books)
              if (b.bookNo != null && savedNos.contains(b.bookNo.toString()))
                b.bookNo!,
          },
        ),
      );
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(booksStatus: LoadStatus.failure, booksError: '100'));
    }
  }

  void _onBookToggled(BookToggled event, Emitter<SelectionState> emit) {
    final selected = {...state.selectedBookNos};
    if (!selected.remove(event.bookNo)) selected.add(event.bookNo);
    emit(state.copyWith(selectedBookNos: selected));
  }

  Future<void> _onBooksConfirmed(
    BooksConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    final selected = state.selectedBooks;
    if (selected.isEmpty) return;

    emit(state.copyWith(booksStatus: LoadStatus.loading));
    try {
      var ids = '';
      for (final book in selected) {
        ids = '$ids${book.bookNo},';
        await _dbRepo.saveBook(book);
      }
      ids = ids.substring(0, ids.length - 1);
      _prefRepo.setPrefString(PrefConstants.selectedBooksKey, ids);
      _prefRepo.setPrefBool(PrefConstants.dataIsSelectedKey, true);
      _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, true);
    } catch (e) {
      logger('Unable to save books: $e');
    }
    emit(state.copyWith(booksStatus: LoadStatus.loaded));
    await _downloadSongs(emit);
  }

  // ── songs download ───────────────────────────────────────────────────────
  Future<void> _downloadSongs(Emitter<SelectionState> emit) async {
    emit(state.copyWith(songsPhase: SongsPhase.fetching, songsProgress: 0));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(songsPhase: SongsPhase.noInternet));
      return;
    }

    final List<Song> songs;
    try {
      final selectedBooks = _prefRepo.getPrefString(
        PrefConstants.selectedBooksKey,
      );
      final resp = await _songRepo.getSongsByBooks(selectedBooks);
      if (resp.statusCode != 200) {
        emit(
          state.copyWith(
            songsPhase: SongsPhase.failed,
            songsError: resp.statusCode.toString(),
          ),
        );
        return;
      }
      final dataList = List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      songs = dataList.map((item) => Song.fromJson(item)).toList();
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(songsPhase: SongsPhase.failed, songsError: '100'));
      return;
    }

    if (songs.isNotEmpty) {
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
        } catch (_) {}
      }
      _prefRepo.setPrefBool(PrefConstants.dataIsLoadedKey, true);
      _prefRepo.setPrefBool(PrefConstants.wakeLockCheckKey, true);
    }

    emit(state.copyWith(songsPhase: SongsPhase.done));
    _completed(SelectionStepType.songbooks, emit);
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

  // ── bibles ───────────────────────────────────────────────────────────────
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
          selectedAbbrs: _bibleRepo.selectedAbbrs.where(known.contains).toList(),
          maxSelections: _bibleRepo.isFirstInstall
              ? bibleFirstInstallMax
              : bibleFirstInstallMax + bibleAdditionalAllowed,
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

  Future<void> _downloadBible(
    Emitter<SelectionState> emit, {
    required String startStep,
    double startProgress = 0,
    Future<void> Function()? beforeDownload,
    required String failMessage,
  }) async {
    emit(
      state.copyWith(
        bibleStatus: BibleStatus.saving,
        bibleStep: startStep,
        bibleProgress: startProgress,
      ),
    );
    var lastProgress = startProgress;
    try {
      if (beforeDownload != null) await beforeDownload();
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
    } catch (e) {
      logger('BibleSelection download failed: $e');
      emit(
        state.copyWith(
          bibleStatus: BibleStatus.saveFailed,
          bibleMessage: failMessage,
          bibleProgress: lastProgress,
        ),
      );
      return;
    }
    _completed(SelectionStepType.bibles, emit);
  }

  Future<void> _onBiblesConfirmed(
    BiblesConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    await _downloadBible(
      emit,
      startStep: 'Preparing...',
      beforeDownload: () => _bibleRepo.persistSelection(_selectedDtos),
      failMessage:
          'Failed to download the Bible. You can continue where it left off or restart.',
    );
  }

  Future<void> _onBibleResumed(
    BibleDownloadResumed event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    final primary = state.selectedAbbrs.first;
    await _downloadBible(
      emit,
      startStep: 'Resuming download...',
      startProgress: await _bibleRepo.savedProgress(primary),
      failMessage:
          "Still couldn't finish the download. You can continue or restart.",
    );
  }

  Future<void> _onBibleRestarted(
    BibleDownloadRestarted event,
    Emitter<SelectionState> emit,
  ) async {
    if (!state.canProceedBibles) return;
    final primary = state.selectedAbbrs.first;
    await _downloadBible(
      emit,
      startStep: 'Restarting download...',
      beforeDownload: () => _bibleRepo.restart(primary),
      failMessage:
          'Failed to download the Bible. You can continue where it left off or restart.',
    );
  }
}
