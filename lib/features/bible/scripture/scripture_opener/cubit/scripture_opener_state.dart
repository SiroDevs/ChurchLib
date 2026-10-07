part of 'scripture_opener_cubit.dart';

class ScriptureOpenerState {
  final bool isLoading;
  final String? error;
  final String bibleAbbr;
  final String bibleName;
  final List<ScriptureSearchRowState> rows;

  const ScriptureOpenerState({
    this.isLoading = true,
    this.error,
    this.bibleAbbr = '',
    this.bibleName = '',
    this.rows = const [],
  });

  ScriptureSearchRowState? get activeRow =>
      rows.where((r) => !r.locked).lastOrNull;

  ScriptureOpenerState copyWith({
    bool? isLoading,
    Object? error = _unset,
    String? bibleAbbr,
    String? bibleName,
    List<ScriptureSearchRowState>? rows,
  }) {
    return ScriptureOpenerState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      bibleAbbr: bibleAbbr ?? this.bibleAbbr,
      bibleName: bibleName ?? this.bibleName,
      rows: rows ?? this.rows,
    );
  }
}
