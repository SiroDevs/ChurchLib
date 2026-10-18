part of 'selection_bloc.dart';

mixin BibleSelectionHandlers on Bloc<SelectionEvent, SelectionState> {
  BibleSelectionRepo get _bibleRepo;
  bool get _finishAfterSave;
  Future<void> _next(Emitter<SelectionState> emit);
  Future<void> _runSave(
    Emitter<SelectionState> emit, {
    required bool finish,
    _BibleRun? bibleRun,
  });

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
