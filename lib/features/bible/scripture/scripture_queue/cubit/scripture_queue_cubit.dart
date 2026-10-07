// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../data/models/bible/scripture_item.dart';

part 'scripture_queue_state.dart';

class ScriptureQueueCubit extends Cubit<ScriptureQueueState> {
  ScriptureQueueCubit() : super(const ScriptureQueueState());

  void open(
    int listId,
    String listName,
    List<ScriptureItem> items, {
    int? activeItemId,
  }) {
    emit(ScriptureQueueState(
      listId: listId,
      listName: listName,
      items: items,
      activeItemId: activeItemId ?? (items.isEmpty ? null : items.first.id),
    ));
  }

  void setActiveItem(int itemId) {
    if (state.items.any((i) => i.id == itemId)) {
      emit(ScriptureQueueState(
        listId: state.listId,
        listName: state.listName,
        items: state.items,
        activeItemId: itemId,
      ));
    }
  }

  void syncActiveByChapter(String bibleAbbr, String chapterId) {
    final match = state.items
        .where((i) => i.bibleAbbr == bibleAbbr && i.chapterId == chapterId)
        .firstOrNull;
    if (match?.id != null) setActiveItem(match!.id!);
  }

  void dismiss() => emit(const ScriptureQueueState());
}
