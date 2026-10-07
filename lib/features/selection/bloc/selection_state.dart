part of 'selection_bloc.dart';

enum SelectionStepType {
  /// Which app(s) to set up — SongLib, BibleLib or both.
  modules('Apps'),

  /// Pick songbooks; their songs are downloaded right after.
  songbooks('Songbooks'),

  /// Pick Bibles; the primary one is downloaded right after.
  bibles('Bibles');

  const SelectionStepType(this.label);
  final String label;
}

enum LoadStatus { idle, loading, loaded, failure, noInternet }

enum SongsPhase { idle, fetching, saving, failed, noInternet, done }

enum BibleStatus { loading, loaded, error, saving, saveFailed, saved }

class SelectionState extends Equatable {
  const SelectionState({
    required this.steps,
    this.index = 0,
    this.songlib = true,
    this.biblelib = true,
    this.finishing = false,
    this.booksStatus = LoadStatus.idle,
    this.books = const [],
    this.selectedBookNos = const {},
    this.booksError = '',
    this.songsPhase = SongsPhase.idle,
    this.songsProgress = 0,
    this.songsFeedback = '',
    this.songsError = '',
    this.bibleStatus = BibleStatus.loading,
    this.availableBibles = const [],
    this.selectedAbbrs = const [],
    this.maxSelections = bibleFirstInstallMax,
    this.bibleMessage = '',
    this.bibleStep = 'Preparing...',
    this.bibleProgress = 0,
  });

  // ── flow ──
  /// The steps this run needs, in order. A first install is
  /// `[modules, songbooks?, bibles?]`, so one app gives 2 steps and both
  /// gives 3. Re-running one module from Settings has just that step.
  final List<SelectionStepType> steps;
  final int index;
  final bool songlib;
  final bool biblelib;

  /// Everything is downloaded; "getting ready" shows and Home opens next.
  final bool finishing;

  // ── songbooks ──
  final LoadStatus booksStatus;
  final List<SongBook> books;
  final Set<int> selectedBookNos;
  final String booksError;

  // ── songs download ──
  final SongsPhase songsPhase;
  final int songsProgress;
  final String songsFeedback;
  final String songsError;

  // ── bibles ──
  final BibleStatus bibleStatus;

  /// Every available translation; the first of [selectedAbbrs] is primary.
  final List<BibleInfoDto> availableBibles;
  final List<String> selectedAbbrs;
  final int maxSelections;
  final String bibleMessage;
  final String bibleStep;
  final double bibleProgress;

  SelectionStepType? get current => index < steps.length ? steps[index] : null;

  bool get canGoBack => index == 1 && steps.first == SelectionStepType.modules;

  List<SongBook> get selectedBooks => [
        for (final b in books)
          if (selectedBookNos.contains(b.bookNo)) b,
      ];

  bool get canProceedBibles => selectedAbbrs.isNotEmpty;

  SelectionState copyWith({
    List<SelectionStepType>? steps,
    int? index,
    bool? songlib,
    bool? biblelib,
    bool? finishing,
    LoadStatus? booksStatus,
    List<SongBook>? books,
    Set<int>? selectedBookNos,
    String? booksError,
    SongsPhase? songsPhase,
    int? songsProgress,
    String? songsFeedback,
    String? songsError,
    BibleStatus? bibleStatus,
    List<BibleInfoDto>? availableBibles,
    List<String>? selectedAbbrs,
    int? maxSelections,
    String? bibleMessage,
    String? bibleStep,
    double? bibleProgress,
  }) =>
      SelectionState(
        steps: steps ?? this.steps,
        index: index ?? this.index,
        songlib: songlib ?? this.songlib,
        biblelib: biblelib ?? this.biblelib,
        finishing: finishing ?? this.finishing,
        booksStatus: booksStatus ?? this.booksStatus,
        books: books ?? this.books,
        selectedBookNos: selectedBookNos ?? this.selectedBookNos,
        booksError: booksError ?? this.booksError,
        songsPhase: songsPhase ?? this.songsPhase,
        songsProgress: songsProgress ?? this.songsProgress,
        songsFeedback: songsFeedback ?? this.songsFeedback,
        songsError: songsError ?? this.songsError,
        bibleStatus: bibleStatus ?? this.bibleStatus,
        availableBibles: availableBibles ?? this.availableBibles,
        selectedAbbrs: selectedAbbrs ?? this.selectedAbbrs,
        maxSelections: maxSelections ?? this.maxSelections,
        bibleMessage: bibleMessage ?? this.bibleMessage,
        bibleStep: bibleStep ?? this.bibleStep,
        bibleProgress: bibleProgress ?? this.bibleProgress,
      );

  @override
  List<Object?> get props => [
        steps,
        index,
        songlib,
        biblelib,
        finishing,
        booksStatus,
        books,
        selectedBookNos,
        booksError,
        songsPhase,
        songsProgress,
        songsFeedback,
        songsError,
        bibleStatus,
        availableBibles,
        selectedAbbrs,
        maxSelections,
        bibleMessage,
        bibleStep,
        bibleProgress,
      ];
}
