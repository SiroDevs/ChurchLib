part of 'song_search_bloc.dart';

enum SongSearchStatus {
  initial,
  loading,
  loaded,
  filtering,
  failure,
  reset,
  noInternet,
}

const _unsetSongSearchValue = Object();

class SongSearchState extends Equatable {
  const SongSearchState({
    this.status = SongSearchStatus.initial,
    this.books = const [],
    this.allSongs = const [],
    this.selectedSongs = const [],
    this.likes = const [],
    this.selectedBook,
    this.feedback,
  });

  final SongSearchStatus status;
  final List<SongBook> books;
  final List<SongExt> allSongs;
  final List<SongExt> selectedSongs;
  final List<SongExt> likes;
  final SongBook? selectedBook;
  final String? feedback;

  SongSearchState copyWith({
    SongSearchStatus? status,
    List<SongBook>? books,
    List<SongExt>? allSongs,
    List<SongExt>? selectedSongs,
    List<SongExt>? likes,
    Object? selectedBook = _unsetSongSearchValue,
    Object? feedback = _unsetSongSearchValue,
  }) {
    return SongSearchState(
      status: status ?? this.status,
      books: books ?? this.books,
      allSongs: allSongs ?? this.allSongs,
      selectedSongs: selectedSongs ?? this.selectedSongs,
      likes: likes ?? this.likes,
      selectedBook: identical(selectedBook, _unsetSongSearchValue)
          ? this.selectedBook
          : selectedBook as SongBook?,
      feedback: identical(feedback, _unsetSongSearchValue)
          ? this.feedback
          : feedback as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    books,
    allSongs,
    selectedSongs,
    likes,
    selectedBook,
    feedback,
  ];
}
