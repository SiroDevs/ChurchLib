part of '../songs_screen.dart';

class SongViewer extends StatelessWidget {
  final SongExt song;

  const SongViewer({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final verses = song.content.split('##');
    return ListView.builder(
      itemCount: verses.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            verses[index].replaceAll('#', '\n'),
            style: const TextStyle(fontSize: 16),
          ).padding(all: 10),
        );
      },
    );
  }
}

String songHeaderTitle(SongExt song) {
  final title = songItemTitle(song.songNo, song.title);
  final book = refineTitle(song.songbook);
  return book.isEmpty ? title : '$title · $book';
}

Future<void> copySongToClipboard(BuildContext context, SongExt song) async {
  final verses = song.content.split('##').map((v) => v.replaceAll('#', '\n'));
  final text =
      '${songItemTitle(song.songNo, song.title)}\n\n${verses.join('\n\n')}';
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Song copied to clipboard'),
      duration: Duration(seconds: 2),
    ),
  );
}
