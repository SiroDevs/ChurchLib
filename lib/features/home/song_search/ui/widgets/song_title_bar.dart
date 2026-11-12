part of '../song_search_screen.dart';

class SongTitleBar extends StatelessWidget {
  const SongTitleBar({super.key, required this.parent});

  final SongSearchScreenState parent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme.titleLarge;
    final onSearchPage = parent.currentPage == PageType.search;
    final song = parent.selectedSong;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: onSearchPage
                ? SearchWidget(
                    searchFocus: parent.searchFocus,
                    searchController: parent.searchController,
                    onSearch: parent.onSearch,
                  )
                : Text(l10n.likesTitle, style: text).padding(left: 6),
          ),
        ).expanded(flex: 1),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (onSearchPage && song.songId != 0)
              Text(
                songHeaderTitle(song),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text,
              ).padding(horizontal: 16).expanded(),

            PresentationToggle(
              module: AppModule.songlib,
              onPresent: parent.presentSelected,
              iconOnly: true,
              enabled: song.songId != 0,
            ),

            IconButton(
              tooltip: l10n.copySong,
              onPressed: () => copySongToClipboard(context, song),
              icon: const Icon(Icons.copy),
            ),
          ],
        ).expanded(flex: 1),
      ],
    );
  }
}
