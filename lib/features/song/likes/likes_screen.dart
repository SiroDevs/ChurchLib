// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../common/widgets/list_items/search_song_item.dart';
import '../../../common/widgets/state/general_progress.dart';
import '../../../common/windows/open_windows.dart';
import '../../../data/models/song/songbook.dart';
import '../../../data/models/song/songext.dart';
import '../../home/song_search/bloc/song_search_bloc.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongSearchBloc, SongSearchState>(
      builder: (context, state) {
        if (state.status == SongSearchStatus.loaded && state.likes.isNotEmpty) {
          return ListView.builder(
            itemCount: state.likes.length,
            itemBuilder: (context, index) {
              final SongExt like = state.likes[index];
              return SearchSongItem(
                song: like,
                height: 50,
                onTap: () {
                  SongBook? book;
                  for (final candidate in state.books) {
                    if (candidate.bookId == like.book) book = candidate;
                  }
                  if (book == null) return;
                  openPresentor(
                    context,
                    song: like,
                    book: book,
                    songs: state.allSongs
                        .where((song) => song.book == like.book)
                        .toList(),
                  );
                },
              );
            },
          );
        } else {
          return EmptyState(title: 'You have not liked a song yet.');
        }
      },
    );
  }
}
