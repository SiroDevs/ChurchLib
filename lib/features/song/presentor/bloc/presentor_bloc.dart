// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/date_util.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/shared/entry_source.dart';
import '../../../../data/models/shared/history_entry.dart';
import '../../../../data/models/song/songext.dart';
import '../../../../domain/repos/database_repo.dart';
import '../utils/presentor_utils.dart';

part 'presentor_event.dart';
part 'presentor_state.dart';


class PresentorBloc extends Bloc<PresentorEvent, PresentorState> {
  PresentorBloc() : super(const _PresentorState()) {
    on<LoadSong>(_onLoadSong);
    on<LikeSong>(_onLikeSong);
    on<SaveHistory>(_onSaveHistory);
  }

  final _dbRepo = getIt<DatabaseRepo>();

  Future<void> _onLoadSong(LoadSong event, Emitter<PresentorState> emit) async {
    emit(PresentorProgressState());
    var presentor = await loadSong(event.song);
    emit(PresentorLoadedState(presentor['tabs'], presentor['stanzas']));
  }

  Future<void> _onLikeSong(LikeSong event, Emitter<PresentorState> emit) async {
    try {
      await _dbRepo.updateSong(
        event.song.rid,
        event.song.title,
        event.song.content,
        !event.song.liked,
        getIso8601Date(),
      );
    } catch (e) {
      logger('Unable to update song: $e');
    }

    emit(PresentorLikedState(!event.song.liked));
  }

  Future<void> _onSaveHistory(
    SaveHistory event,
    Emitter<PresentorState> emit,
  ) async {
    await _dbRepo.saveHistory(
      HistoryEntry(
        source: EntrySource.song,
        refId: '${event.song.rid}',
        occurredAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    emit(PresentorHistoryState());
  }
}
