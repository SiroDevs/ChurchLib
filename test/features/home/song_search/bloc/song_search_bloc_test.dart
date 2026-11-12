import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:churchlib/data/models/song/songbook.dart';
import 'package:churchlib/data/models/song/songext.dart';
import 'package:churchlib/domain/repos/database_repo.dart';
import 'package:churchlib/domain/repos/pref_repo.dart';
import 'package:churchlib/domain/repos/song/song_selection_repo.dart';
import 'package:churchlib/domain/repos/song/song_sync_repo.dart';
import 'package:churchlib/features/home/song_search/bloc/song_search_bloc.dart';

void main() {
  test('a late book filter cannot replace the latest selection', () async {
    final database = _DelayedDatabaseRepo();
    final preferences = _UnusedPrefRepo();
    final bloc = SongSearchBloc(
      syncRepo: SongSyncRepo(preferences, database, SongSelectionRepo()),
      prefRepo: preferences,
      databaseRepo: database,
    );
    final loadedState = bloc.stream.firstWhere(
      (state) =>
          state.status == SongSearchStatus.loaded && state.books.length == 2,
    );
    bloc.add(const FetchData());
    final loaded = await loadedState;

    final firstBookFilter = bloc.stream.firstWhere(
      (state) => state.status == SongSearchStatus.filtering,
    );
    bloc.add(FilterData(loaded.books[0]));
    await firstBookFilter;

    final secondBookLoaded = bloc.stream.firstWhere(
      (state) =>
          state.status == SongSearchStatus.loaded &&
          state.selectedBook?.bookId == 2,
    );
    bloc.add(FilterData(loaded.books[1]));
    database.secondBookSongs.complete([_song(2)]);
    await secondBookLoaded;

    database.firstBookSongs.complete([_song(1)]);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.selectedBook?.bookId, 2);
    expect(bloc.state.selectedSongs.single.book, 2);
    await bloc.close();
  });
}

SongExt _song(int bookId) =>
    SongExt(bookId, bookId, bookId, 1, 'Song', '', '', 0, 0, false, 'Book');

class _DelayedDatabaseRepo implements DatabaseRepo {
  final firstBookSongs = Completer<List<SongExt>>();
  final secondBookSongs = Completer<List<SongExt>>();

  @override
  Future<List<SongBook>> fetchBooks() async => [
    SongBook(bookId: 1, title: 'First'),
    SongBook(bookId: 2, title: 'Second'),
  ];

  @override
  Future<List<SongExt>> fetchSongs({int bid = 0}) {
    if (bid == 1) return firstBookSongs.future;
    if (bid == 2) return secondBookSongs.future;
    return Future.value(const []);
  }

  @override
  Future<List<SongExt>> fetchLikes() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPrefRepo implements PrefRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
