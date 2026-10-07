// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/scripture_item.dart';
import '../../../../domain/repos/bible/scripture_repo.dart';

enum ScriptureListDetailStatus { loading, loaded, error }

class ScriptureListDetailState {
  final ScriptureListDetailStatus status;
  final String name;
  final List<ScriptureItem> items;
  final String? error;

  const ScriptureListDetailState({
    this.status = ScriptureListDetailStatus.loading,
    this.name = '',
    this.items = const [],
    this.error,
  });

  ScriptureListDetailState copyWith({
    ScriptureListDetailStatus? status,
    String? name,
    List<ScriptureItem>? items,
    String? error,
  }) {
    return ScriptureListDetailState(
      status: status ?? this.status,
      name: name ?? this.name,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

class ScriptureListDetailCubit extends Cubit<ScriptureListDetailState> {
  final _repo = getIt<ScriptureRepo>();
  final int listId;

  ScriptureListDetailCubit(this.listId)
      : super(const ScriptureListDetailState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: ScriptureListDetailStatus.loading));
    final list = await _repo.getList(listId);
    final items = await _repo.getItems(listId);
    if (list == null || items.isEmpty) {
      emit(state.copyWith(
        status: ScriptureListDetailStatus.error,
        error: 'This scripture list could not be found.',
      ));
      return;
    }
    emit(state.copyWith(
      status: ScriptureListDetailStatus.loaded,
      name: list.name,
      items: items,
    ));
  }

  Future<void> rename(String name) async {
    await _repo.renameList(listId, name);
    emit(state.copyWith(name: name));
  }
}
