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
part 'selection_bibles_handlers.dart';
part 'selection_songs_handlers.dart';
part 'selection_state.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState>
    with SongSelectionHandlers, BibleSelectionHandlers {
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
}
