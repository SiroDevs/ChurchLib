part of '../songs_screen.dart';

class SongViewer extends StatefulWidget {
  final SongExt song;
  final List<SongBook> books;
  final List<SongExt> songs;
  const SongViewer({
    super.key,
    required this.song,
    required this.books,
    required this.songs,
  });

  @override
  State<SongViewer> createState() => SongViewerState();
}

class SongViewerState extends State<SongViewer> {
  late SongSearchBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<SongSearchBloc>();
  }

  Future<void> onCopy() async {
    final song = widget.song;
    final verses = song.content.split("##").map((v) => v.replaceAll("#", "\n"));
    final text = '${songItemTitle(song.songNo, song.title)}\n\n${verses.join("\n\n")}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Song copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> onPresent() async {
    SongBook book = widget.books[0];
    try {
      widget.books.firstWhere(
        (b) => b.bookId == widget.song.book,
        orElse: () => widget.books[0],
      );
    } catch (e) {
      logger('Failed to get the book: $e');
    }

    bool? result = await context.pushNamed<bool>(
      RouteNames.presentor,
      extra: (song: widget.song, book: book, songs: widget.songs),
    );

    if (result == true) {
      bloc.add(FilterData(book));
    }
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    List<String> verses = widget.song.content.split("##");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          songViewerTitle(widget.song),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Tooltip(
            message: l10n.copySong,
            child: IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView.builder(
        itemCount: verses.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              verses[index].replaceAll("#", "\n"),
              style: TextStyle(fontSize: 16),
            ).padding(all: 10),
          );
        },
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: widget.song.liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: widget.song.liked ? 'Liked' : 'Like',
                  tooltip: widget.song.liked
                      ? l10n.songDislike
                      : l10n.songLike,
                  onTap: () {},
                ),
                _ActionButton(
                  icon: Icons.north_east,
                  label: 'Present',
                  tooltip: l10n.projectSong,
                  onTap: onPresent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

String songViewerTitle(SongExt song) {
  final title = songItemTitle(song.songNo, song.title);
  final book = refineTitle(song.songbook);
  return book.isEmpty ? title : '$title · $book';
}
