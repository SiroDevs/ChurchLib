// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../domain/repos/bible/scripture_repo.dart';

class ScriptureListSummary {
  final int id;
  final String name;
  final int createdAt;
  final int itemCount;

  ScriptureListSummary(this.id, this.name, this.createdAt, this.itemCount);
}

enum ScriptureListsStatus { loading, loaded, error }

class ScriptureListsState {
  final ScriptureListsStatus status;
  final List<ScriptureListSummary> lists;
  final String? error;

  const ScriptureListsState({
    this.status = ScriptureListsStatus.loading,
    this.lists = const [],
    this.error,
  });

  ScriptureListsState copyWith({
    ScriptureListsStatus? status,
    List<ScriptureListSummary>? lists,
    String? error,
  }) {
    return ScriptureListsState(
      status: status ?? this.status,
      lists: lists ?? this.lists,
      error: error ?? this.error,
    );
  }
}

class ScriptureListsCubit extends Cubit<ScriptureListsState> {
  final _repo = getIt<ScriptureRepo>();

  ScriptureListsCubit() : super(const ScriptureListsState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: ScriptureListsStatus.loading));
    try {
      final lists = await _repo.getAllLists();
      final summaries = <ScriptureListSummary>[];
      for (final l in lists) {
        final count = await _repo.getItemCount(l.id!);
        summaries.add(ScriptureListSummary(l.id!, l.name, l.createdAt, count));
      }
      emit(state.copyWith(
        status: ScriptureListsStatus.loaded,
        lists: summaries,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ScriptureListsStatus.error,
        error: 'Failed to load scripture lists.',
      ));
    }
  }

  Future<void> delete(int listId) async {
    await _repo.deleteList(listId);
    await load();
  }
}
