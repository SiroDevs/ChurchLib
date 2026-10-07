part of 'scripture_lists_cubit.dart';

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
