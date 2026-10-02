import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/bible/scripture_item.dart';

class ScriptureQueueState {
  final int? listId;
  final String listName;
  final List<ScriptureItem> items;
  final int? activeItemId;

  const ScriptureQueueState({
    this.listId,
    this.listName = '',
    this.items = const [],
    this.activeItemId,
  });

  /// True while a queue is open and should be shown in place of the
  /// chapter navigation bar.
  bool get isOpen => items.isNotEmpty;

  ScriptureItem? get activeItem =>
      items.where((i) => i.id == activeItemId).firstOrNull;

  int get activeIndex => items.indexWhere((i) => i.id == activeItemId);
}

/// Holds the scripture list currently "open" in the reader — the floating
/// queue widget that replaces the chapter nav bar. In-memory/session-scoped
/// only; the persisted data lives in [ScriptureRepository]. Registered as a
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
