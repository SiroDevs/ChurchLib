// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../data/models/bible/scripture_item.dart';

part 'scripture_queue_state.dart';

/// Holds the scripture list currently "open" in the reader — the floating
/// queue widget that replaces the chapter nav bar. In-memory/session-scoped
/// only; the persisted data lives in [ScriptureRepo]. Registered as a
/// DI singleton so it's shared between the Scripture Opener, Scripture
/// Lists screens and the reader, like Android's `@Singleton
/// ScriptureQueueRepo`.
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

  /// Marks whichever item best matches the chapter currently on screen as
  /// active, so the floating widget stays in sync as the user navigates
  /// chapters normally (not just via the queue's own next/previous).
  void syncActiveByChapter(String bibleAbbr, String chapterId) {
    final match = state.items
        .where((i) => i.bibleAbbr == bibleAbbr && i.chapterId == chapterId)
        .firstOrNull;
    if (match?.id != null) setActiveItem(match!.id!);
  }

  void dismiss() => emit(const ScriptureQueueState());
}
