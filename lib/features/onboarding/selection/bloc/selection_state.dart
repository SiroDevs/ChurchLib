part of 'selection_bloc.dart';

const maxBibleSelections = 10;
const maxSongbookSelections = 10;

enum SelectionStepType {
  modules('Apps'),

  songs('Songs'),

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
    this.saveActive = false,
    this.planSongs = false,
    this.planBible = false,
    this.booksStatus = LoadStatus.idle,
    this.books = const [],
    this.selectedBookIds = const {},
    this.booksError = '',
    this.songsPhase = SongsPhase.idle,
    this.songsProgress = 0,
    this.songsFeedback = '',
    this.songsError = '',
    this.bibleStatus = BibleStatus.loading,
    this.availableBibles = const [],
    this.selectedAbbrs = const [],
    this.maxSelections = maxBibleSelections,
    this.bibleMessage = '',
    this.bibleStep = 'Preparing...',
    this.bibleProgress = 0,
  });

  final List<SelectionStepType> steps;
  final int index;
  final bool songlib;
  final bool biblelib;

  final bool finishing;

  final bool saveActive;

  final bool planSongs;
  final bool planBible;

  final LoadStatus booksStatus;
  final List<SongBook> books;
  final Set<int> selectedBookIds;
  final String booksError;

  final SongsPhase songsPhase;
  final int songsProgress;
  final String songsFeedback;
  final String songsError;

  final BibleStatus bibleStatus;

  final List<BibleInfoDto> availableBibles;
  final List<String> selectedAbbrs;
  final int maxSelections;
  final String bibleMessage;
  final String bibleStep;
  final double bibleProgress;

  SelectionStepType? get current => index < steps.length ? steps[index] : null;

  bool get canGoBack => index > 0 && !saveActive && !finishing;

  List<SongBook> get selectedBooks => [
    for (final b in books)
      if (selectedBookIds.contains(b.bookId)) b,
  ];

  bool get canProceedBibles => selectedAbbrs.isNotEmpty;

  double get saveProgress {
    final songs = songsPhase == SongsPhase.done
        ? 1.0
        : (songsPhase == SongsPhase.saving ? songsProgress / 100 : 0.0);
    final bible = bibleProgress.clamp(0.0, 1.0);
    if (planSongs && planBible) return 0.5 * songs + 0.5 * bible;
    return planSongs ? songs : bible;
  }

  SelectionState copyWith({
    List<SelectionStepType>? steps,
    int? index,
    bool? songlib,
    bool? biblelib,
    bool? finishing,
    bool? saveActive,
    bool? planSongs,
    bool? planBible,
    LoadStatus? booksStatus,
    List<SongBook>? books,
    Set<int>? selectedBookIds,
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
  }) => SelectionState(
    steps: steps ?? this.steps,
    index: index ?? this.index,
    songlib: songlib ?? this.songlib,
    biblelib: biblelib ?? this.biblelib,
    finishing: finishing ?? this.finishing,
    saveActive: saveActive ?? this.saveActive,
    planSongs: planSongs ?? this.planSongs,
    planBible: planBible ?? this.planBible,
    booksStatus: booksStatus ?? this.booksStatus,
    books: books ?? this.books,
    selectedBookIds: selectedBookIds ?? this.selectedBookIds,
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
    saveActive,
    planSongs,
    planBible,
    booksStatus,
    books,
    selectedBookIds,
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
