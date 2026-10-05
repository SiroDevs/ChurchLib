part of 'song_search_bloc.dart';

@freezed
class SongSearchState with _$SongSearchState {
  const factory SongSearchState.initial() = _MainState;

  const factory SongSearchState.loaded() = LoadedState;

  const factory SongSearchState.fetched(
    List<SongBook> books,
    List<SongExt> songs,
  ) = DataFetchedState;

  const factory SongSearchState.synced(
    List<SongBook> books,
    List<SongExt> songs,
  ) = DataSyncedState;

  const factory SongSearchState.filtered(
    SongBook book,
    List<SongExt> songs,
    List<SongExt> likes,
  ) = FilteredState;

  const factory SongSearchState.fetching() = FetchingState;

  const factory SongSearchState.filtering() = FilteringState;

  const factory SongSearchState.success() = SuccessState;

  const factory SongSearchState.reset() = ResettedState;

  const factory SongSearchState.failure(String feedback) = FailureState;

  const factory SongSearchState.noInternet() = NoInternetState;
  
  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    throw UnimplementedError();
  }
  
  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    throw UnimplementedError();
  }
  
  @override
  String toStringDeep({String prefixLineOne = '', String? prefixOtherLines, DiagnosticLevel minLevel = DiagnosticLevel.debug, int wrapWidth = 65}) {
    throw UnimplementedError();
  }
  
  @override
  String toStringShallow({String joiner = ', ', DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    throw UnimplementedError();
  }
  
  @override
  String toStringShort() {
    throw UnimplementedError();
  }
}
