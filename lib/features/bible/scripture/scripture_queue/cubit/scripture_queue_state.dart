part of 'scripture_queue_cubit.dart';

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

  bool get isOpen => items.isNotEmpty;

  ScriptureItem? get activeItem =>
      items.where((i) => i.id == activeItemId).firstOrNull;

  int get activeIndex => items.indexWhere((i) => i.id == activeItemId);
}
