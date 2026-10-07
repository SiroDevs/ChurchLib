// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/scripture_item.dart';
import '../../../../domain/repos/bible/scripture_repo.dart';

part 'scripture_list_detail_state.dart';

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
