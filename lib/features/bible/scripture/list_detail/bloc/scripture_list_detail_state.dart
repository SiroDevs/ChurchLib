part of 'scripture_list_detail_cubit.dart';

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
