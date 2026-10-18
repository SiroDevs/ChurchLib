import 'dart:math';

import '../../../common/utils/display/font_utils.dart';
import '../../../common/utils/formatting/song_text_utils.dart';
import '../../../common/widgets/presentor/presentor.dart';
import '../../../data/models/song/songext.dart';
import '../../bible/reader/bloc/bible_reader_cubit.dart';
import '../../song/presentor/utils/presentor_utils.dart';
import '../ui/audience_screen.dart';
import 'presentation_controller.dart';

Future<void> presentSong(SongExt song) async {
  final loaded = await loadSong(song);
  final stanzas = List<String>.from(loaded['stanzas']);
  if (stanzas.isEmpty) return;
  PresentationController.instance.present(
    PresentationSession(
      title:
          '${songItemTitle(song.songNo, song.title)} - ${refineTitle(song.songbook)}',
      labels: List<String>.from(loaded['labels']),
      items: [for (final s in stanzas) s.replaceAll('#', '\n')],
      slide: (i, h, style) => SliderContent(
        lyrics: stanzas[i],
        fontSize:
            max(24, calcFontSize(height: h, content: song.content)) *
            style.scale,
        fitWith: stanzas,
        textAlign: style.align,
      ),
    ),
  );
}

void presentChapter(BibleReaderState state, {int at = 0}) {
  final verses = state.verses;
  if (verses.isEmpty) return;
  final reference = state.activeChapter?.reference ?? '';
  PresentationController.instance.present(
    PresentationSession(
      title: '${state.activeBible}  ·  ${state.activeBook?.name ?? reference}',
      labels: [for (final v in verses) '${v.number}'],
      items: [for (final v in verses) v.text],
      slide: (i, h, style) => VerseSlide(
        header: '${state.activeBible}  ·  $reference:${verses[i].number}',
        text: verses[i].text,
        height: h,
        style: style,
      ),
    ),
    at: at,
  );
}
