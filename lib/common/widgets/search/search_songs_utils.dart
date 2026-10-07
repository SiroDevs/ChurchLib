// Project imports:
import '../../utils/app_util.dart';
import '../../../data/models/song/songext.dart';

List<SongExt> filterSongsByQuery(String query, List<SongExt> songs) {
  return songs.where((song) {
    if (isNumeric(query) && song.songNo == int.parse(query)) {
      return true;
    }

    final charsPtn = RegExp(r'[!,]');
    final words = query.contains(',')
        ? query.split(',').map((w) => w.trim()).toList()
        : [query];
    final queryPtn = RegExp(words.map((w) => '($w)').join('.*'));

    final title = song.title.replaceAll(charsPtn, '').toLowerCase();
    final alias = song.alias.replaceAll(charsPtn, '').toLowerCase();
    final content = song.content.replaceAll(charsPtn, '').toLowerCase();

    return (song.title.isNotEmpty && queryPtn.hasMatch(title)) ||
        (song.alias.isNotEmpty && queryPtn.hasMatch(alias)) ||
        (song.content.isNotEmpty && queryPtn.hasMatch(content));
  }).toList();
}
