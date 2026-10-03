// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/network_utils.dart';
import '../../../../data/sources/remote/bible/bible_dtos.dart';
import '../../../../domain/repos/bible/bible_selection_repo.dart';

sealed class BibleSelectionEvent {
  const BibleSelectionEvent();
}

class BibleSelectionFetch extends BibleSelectionEvent {
  const BibleSelectionFetch();
}

class BibleSelectionToggle extends BibleSelectionEvent {
  final String abbr;
  const BibleSelectionToggle(this.abbr);
}

/// Save the selection and download the primary translation.
class BibleSelectionSave extends BibleSelectionEvent {
  const BibleSelectionSave();
}

/// Resume the primary download from where it stopped.
class BibleSelectionContinue extends BibleSelectionEvent {
  const BibleSelectionContinue();
}

/// Clear the primary's partial content and download it again.
class BibleSelectionRestart extends BibleSelectionEvent {
  const BibleSelectionRestart();
}

enum BibleSelectionPhase { loading, loaded, error, saving, saveFailed, saved }

class BibleSelectionState {
  final BibleSelectionPhase phase;

  /// Every available translation, in the order the user picked them first
  /// (see [selectedAbbrs]); the first selected is the primary.
  final List<BibleInfoDto> available;
  final List<String> selectedAbbrs;
  final int maxSelections;
  final String message;
  final String step;
  final double progress;

  const BibleSelectionState({
    this.phase = BibleSelectionPhase.loading,
    this.available = const [],
    this.selectedAbbrs = const [],
    this.maxSelections = bibleFirstInstallMax,
    this.message = '',
    this.step = 'Preparing...',
    this.progress = 0,
  });

  bool get canProceed => selectedAbbrs.isNotEmpty;

  BibleSelectionState copyWith({
    BibleSelectionPhase? phase,
    List<BibleInfoDto>? available,
    List<String>? selectedAbbrs,
    int? maxSelections,
    String? message,
    String? step,
    double? progress,
  }) =>
      BibleSelectionState(
        phase: phase ?? this.phase,
        available: available ?? this.available,
        selectedAbbrs: selectedAbbrs ?? this.selectedAbbrs,
        maxSelections: maxSelections ?? this.maxSelections,
        message: message ?? this.message,
        step: step ?? this.step,
        progress: progress ?? this.progress,
      );
}

class BibleSelectionBloc
    extends Bloc<BibleSelectionEvent, BibleSelectionState> {
  final _repo = BibleSelectionRepo();

  BibleSelectionBloc() : super(const BibleSelectionState()) {
    on<BibleSelectionFetch>(_onFetch);
    on<BibleSelectionToggle>(_onToggle);
    on<BibleSelectionSave>(_onSave);
    on<BibleSelectionContinue>(_onContinue);
    on<BibleSelectionRestart>(_onRestart);
  }

  List<BibleInfoDto> get _selectedDtos => [
        for (final abbr in state.selectedAbbrs)
          ...state.available.where((b) => b.abbreviation == abbr),
      ];

  Future<void> _onFetch(
    BibleSelectionFetch event,
    Emitter<BibleSelectionState> emit,
  ) async {
    emit(state.copyWith(phase: BibleSelectionPhase.loading));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(
        phase: BibleSelectionPhase.error,
        message: 'No internet connection. Connect and try again.',
      ));
      return;
    }
    try {
      final available = await _repo.fetchAvailable();
      final known = available.map((b) => b.abbreviation).toSet();
      emit(state.copyWith(
        phase: BibleSelectionPhase.loaded,
        available: available,
        selectedAbbrs: _repo.selectedAbbrs.where(known.contains).toList(),
        maxSelections: _repo.isFirstInstall
            ? bibleFirstInstallMax
            : bibleFirstInstallMax + bibleAdditionalAllowed,
      ));
    } catch (e) {
      logger('BibleSelection fetch failed: $e');
      emit(state.copyWith(
        phase: BibleSelectionPhase.error,
        message:
            'Could not load Bibles. Please check your connection and try again.',
      ));
    }
  }

  void _onToggle(
    BibleSelectionToggle event,
    Emitter<BibleSelectionState> emit,
  ) {
    final selected = [...state.selectedAbbrs];
    if (selected.contains(event.abbr)) {
      selected.remove(event.abbr);
    } else {
      if (selected.length >= state.maxSelections) return;
      selected.add(event.abbr);
    }
    emit(state.copyWith(selectedAbbrs: selected));
  }

  Future<void> _download(
    Emitter<BibleSelectionState> emit, {
    required String startStep,
    double startProgress = 0,
    Future<void> Function()? beforeDownload,
    required String failMessage,
  }) async {
    emit(state.copyWith(
      phase: BibleSelectionPhase.saving,
      step: startStep,
      progress: startProgress,
    ));
    var lastProgress = startProgress;
    try {
      if (beforeDownload != null) await beforeDownload();
      await _repo.downloadPrimaryAndQueueSecondaries(
        _selectedDtos,
        onProgress: (step, progress) async {
          lastProgress = progress;
          if (!isClosed) {
            emit(state.copyWith(step: step, progress: progress));
          }
        },
      );
      emit(state.copyWith(phase: BibleSelectionPhase.saved, progress: 1));
    } catch (e) {
      logger('BibleSelection download failed: $e');
      emit(state.copyWith(
        phase: BibleSelectionPhase.saveFailed,
        message: failMessage,
        progress: lastProgress,
      ));
    }
  }

  Future<void> _onSave(
    BibleSelectionSave event,
    Emitter<BibleSelectionState> emit,
  ) async {
    if (!state.canProceed) return;
    await _download(
      emit,
      startStep: 'Preparing...',
      beforeDownload: () => _repo.persistSelection(_selectedDtos),
      failMessage:
          'Failed to download the Bible. You can continue where it left off or restart.',
    );
  }

  Future<void> _onContinue(
    BibleSelectionContinue event,
    Emitter<BibleSelectionState> emit,
  ) async {
    if (!state.canProceed) return;
    final primary = state.selectedAbbrs.first;
    await _download(
      emit,
      startStep: 'Resuming download...',
      startProgress: await _repo.savedProgress(primary),
      failMessage:
          "Still couldn't finish the download. You can continue or restart.",
    );
  }

  Future<void> _onRestart(
    BibleSelectionRestart event,
    Emitter<BibleSelectionState> emit,
  ) async {
    if (!state.canProceed) return;
    final primary = state.selectedAbbrs.first;
    await _download(
      emit,
      startStep: 'Restarting download...',
      beforeDownload: () => _repo.restart(primary),
      failMessage:
          'Failed to download the Bible. You can continue where it left off or restart.',
    );
  }
}
