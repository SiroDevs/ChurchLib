part of 'bibles_cubit.dart';

class BiblesState {
  final List<BibleVersion> bibles;
  final String primaryAbbr;

  /// abbr -> 0.0-1.0, only for bibles currently downloading in this
  /// session (desktop has no background worker to observe, so this only
  /// reflects downloads started from this screen).
  final Map<String, double> downloadProgress;
  final Set<String> retrying;
  final bool isLoading;
  final bool multiBibleEnabled;
  final List<String> secondaryBibles;

  const BiblesState({
    this.bibles = const [],
    this.primaryAbbr = '',
    this.downloadProgress = const {},
    this.retrying = const {},
    this.isLoading = true,
    this.multiBibleEnabled = true,
    this.secondaryBibles = const [],
  });

  BiblesState copyWith({
    List<BibleVersion>? bibles,
    String? primaryAbbr,
    Map<String, double>? downloadProgress,
    Set<String>? retrying,
    bool? isLoading,
    bool? multiBibleEnabled,
    List<String>? secondaryBibles,
  }) =>
      BiblesState(
        bibles: bibles ?? this.bibles,
        primaryAbbr: primaryAbbr ?? this.primaryAbbr,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        retrying: retrying ?? this.retrying,
        isLoading: isLoading ?? this.isLoading,
        multiBibleEnabled: multiBibleEnabled ?? this.multiBibleEnabled,
        secondaryBibles: secondaryBibles ?? this.secondaryBibles,
      );
}
