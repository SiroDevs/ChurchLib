part of '../song_search_screen.dart';

enum _SongOption { copy, present }

class SongBottomBar extends StatelessWidget {
  const SongBottomBar({super.key, required this.parent});

  final HomeScreenState parent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final song = parent.selectedSong;
    final enabled = song.songId != 0;
    final color = enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: .35);

    return Material(
      color: scheme.secondaryContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const Spacer(),
              PopupMenuButton<_SongOption>(
                enabled: enabled,
                tooltip: 'Quick Options',
                onSelected: (option) => switch (option) {
                  _SongOption.copy => copySongToClipboard(context, song),
                  _SongOption.present => parent.presentSelected(context),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _SongOption.copy,
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Copy song'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _SongOption.present,
                    child: ListTile(
                      leading: Icon(Icons.north_east),
                      title: Text('Present song'),
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 24, color: color),
                      const SizedBox(height: 2),
                      Text(
                        'Quick Options',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
