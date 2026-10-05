// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../common/utils/app_util.dart';
import '../../data/models/song/songbook.dart';
import '../../data/models/song/songext.dart';
import '../../common/navigator/app_routes.dart';
import '../../common/navigator/route_names.dart';
import '../home/song_search/bloc/song_search_bloc.dart';
import '../widgets/list_items/search_song_item.dart';
import '../widgets/progress/general_progress.dart';

class LikesScreen extends StatelessWidget {
  final List<SongBook> books;

  const LikesScreen({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongSearchBloc, SongSearchState>(
      builder: (context, state) {
        if (state is FilteredState && state.likes.isNotEmpty) {
          return ListView.builder(
            itemCount: state.likes.length,
            itemBuilder: (context, index) {
              final SongExt like = state.likes[index];
              return SearchSongItem(
                song: like,
                height: 50,
                onTap: () {
                  SongBook book = books[0];
                  try {
                    book = books.firstWhere((b) => b.bookId == like.book);
                  } catch (e) {
                    logger('Failed to get the book: $e');
                  }
                  context.pushNamed(
                    RouteNames.presentor,
                    extra: (song: like, book: book, songs: state.songs)
                        as PresentorArgs,
                  );
                },
              );
            },
          );
        } else {
          return EmptyState(
            title: 'You have not liked a song yet.',
          );
        }
      },
    );
  }
}
