part of '../song_search_screen.dart';

class SongTitleBar extends StatelessWidget {
  const SongTitleBar({super.key, required this.parent});

  final HomeScreenState parent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme.titleLarge;
    final onSearchPage = parent.currentPage == PageType.search;
    final song = parent.selectedSong;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: onSearchPage
                  ? SearchWidget(
                      searchFocus: parent.searchFocus,
                      searchController: parent.searchController,
                      onSearch: parent.onSearch,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(l10n.likesTitle, style: text),
                    ),
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onSearchPage && song.songId != 0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      songHeaderTitle(song),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text,
                    ),
                  ),
                ),

              IconButton(
                tooltip: 'Present Song',
                onPressed: () => parent.presentSelected(context),
                icon: const Icon(Icons.north_east),
              ),

              IconButton(
                tooltip: 'Copy Song',
                onPressed: () => copySongToClipboard(context, song),
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
