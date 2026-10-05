// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../common/utils/app_util.dart';
import '../../core/theme/theme_styles.dart';
import '../../data/models/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/app_intents.dart';
import '../common/search_songs_utils.dart';
import '../../common/navigator/app_routes.dart';
import '../../common/navigator/route_names.dart';
import '../home/song_search/bloc/song_search_bloc.dart';
import '../home/song_search/ui/song_search_screen.dart';
import '../widgets/list_items/search_book_item.dart';
import '../widgets/list_items/search_song_item.dart';

part 'widgets/song_viewer.dart';
part 'widgets/list_widgets.dart';

class SongsScreen extends StatefulWidget {
  final bool isBigScreen;
  final HomeScreenState parent;

  const SongsScreen({
    super.key,
    required this.parent,
    this.isBigScreen = false,
  });

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late SongSearchBloc bloc;
  late HomeScreenState parent;
  late FocusNode searchFocus;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    parent = widget.parent;
    bloc = context.read<SongSearchBloc>();
    searchFocus = FocusNode();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchFocus.dispose();
    searchController.dispose();

    super.dispose();
  }

  Future<void> onSongSelect(SongExt song, bool shouldOpen) async {
    setState(() => parent.selectedSong = song);
    if (shouldOpen) {
      onSongOpen();
    }
  }

  Future<void> onSongOpen() async {
    SongExt song = parent.selectedSong;
    SongBook book = parent.books[0];
    try {
      parent.books.firstWhere(
        (b) => b.bookId == song.book,
        orElse: () => parent.books[0],
      );
    } catch (e) {
      logger('Failed to get the book: $e');
    }

    bool? result = await context.pushNamed<bool>(
      RouteNames.presentor,
      extra: (song: song, book: book, songs: parent.songs) as PresentorArgs,
    );

    if (result == true) {
      bloc.add(FilterData(book));
    }
  }

  void _onSearch(String query) {
    setState(() {
      parent.filtered = query.isEmpty
          ? parent.songs
          : filterSongsByQuery(query.toLowerCase(), parent.songs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        var bigScreenView = Row(
          children: [
            Scaffold(
              appBar: AppBar(
                title: SearchWidget(
                  searchFocus: searchFocus,
                  searchController: searchController,
                  onSearch: _onSearch,
                ),
              ),
              body: Column(
                children: [
                  BooksList(
                    books: parent.books,
                    selectedBook: parent.selectedBook,
                  ),
                  SongsList(
                    selectedSong: parent.selectedSong,
                    songs: parent.filtered,
                    onTap: onSongSelect,
                    isBigScreen: true,
                  ).expanded(),
                ],
              ),
            ).width(dimens.maxWidth / 2.2),
            SongViewer(
              song: parent.selectedSong,
              books: parent.books,
              songs: parent.songs,
            ).expanded(),
          ],
        );
        return Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            CharacterActivator('s'): SearchIntent(),
            SingleActivator(LogicalKeyboardKey.enter): OpenIntent(),
            SingleActivator(LogicalKeyboardKey.escape): CloseIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              SearchIntent: CallbackAction<SearchIntent>(
                onInvoke: (intent) => searchFocus.requestFocus(),
              ),
              OpenIntent: CallbackAction<OpenIntent>(
                onInvoke: (intent) => onSongOpen(),
              ),
            },
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                logger('Key pressed: ${event.logicalKey.keyLabel}');
                return KeyEventResult.ignored;
              },
              child: bigScreenView,
            ),
          ),
        );
      },
    );
  }
}
