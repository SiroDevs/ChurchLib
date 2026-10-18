import 'dart:math';

import '../../../common/utils/display/font_utils.dart';
import '../../../common/utils/formatting/song_text_utils.dart';
import '../../../data/models/song/songext.dart';
import '../../bible/reader/bloc/bible_reader_cubit.dart';
import '../../song/presentor/utils/presentor_utils.dart';
import '../ui/presentation_slide.dart';
import 'presentation_controller.dart';

Future<void> presentSong(SongExt song) async {
  final loaded = await loadSong(song);
  final stanzas = List<String>.from(loaded['stanzas']);
  if (stanzas.isEmpty) return;
  final title =
      '${songItemTitle(song.songNo, song.title)} - ${refineTitle(song.songbook)}';
  final items = [for (final s in stanzas) s.replaceAll('#', '\n')];
  PresentationController.instance.present(
    PresentationSession(
      title: title,
      labels: List<String>.from(loaded['labels']),
      items: items,
      slide: (i, h, style) => PresentationSlide(
        title: title,
        text: items[i],
        fontSize:
            max(24, calcFontSize(height: h, content: song.content)) *
            style.scale,
        fitWith: items,
        style: style,
      ),
    ),
  );
}

void presentBible(BibleReaderState state, {int at = 0}) {
  final verses = state.verses;
  if (verses.isEmpty) return;
  final reference = state.activeChapter?.reference ?? '';
  final title = '${state.activeBible}  ·  $reference';
  PresentationController.instance.present(
    PresentationSession(
      title: title,
      labels: [for (final v in verses) '${v.number}'],
      items: [for (final v in verses) v.text],
      slide: (i, h, style) => PresentationSlide(
        title: title,
        marker: '${verses[i].number}',
        text: verses[i].text,
        fontSize: h * 0.08 * style.scale,
        style: style,
      ),
    ),
    at: at,
  );
}
