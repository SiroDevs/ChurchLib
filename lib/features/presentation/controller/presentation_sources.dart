import 'dart:math';

import '../../../common/utils/display/app_window.dart';
import '../../../common/utils/display/font_utils.dart';
import '../../../common/utils/formatting/song_text_utils.dart';
import '../../../data/models/song/songext.dart';
import '../../home/bible_reader/cubit/bible_reader_cubit.dart';
import '../../song/presentor/utils/presentor_utils.dart';
import '../ui/presentation_slide.dart';
import 'presentation_controller.dart';

Future<void> presentSong(SongExt song) async {
  final loadedSong = await loadSong(song);
  final stanzas = List<String>.from(loadedSong['stanzas']);
  if (stanzas.isEmpty) return;

  final title =
      '${songItemTitle(song.songNo, song.title)} - ${refineTitle(song.songbook)}';
  final labels = List<String>.from(loadedSong['labels']);
  final items = [for (final stanza in stanzas) stanza.replaceAll('#', '\n')];
  PresentationController.instance.present(
    PresentationSession(
      kind: PresentationKind.song,
      title: title,
      labels: labels,
      items: items,
      slide: (slideIndex, screenHeight, style) => PresentationSlide(
        title: title,
        text: items[slideIndex],
        fontSize:
            max(24, calcFontSize(height: screenHeight, content: song.content)) *
            style.scale,
        fitTexts: items,
        style: style,
      ),
    ),
  );
}

void presentBible(BibleReaderState state, {int? at}) {
  final verses = state.verses;
  if (verses.isEmpty) return;

  if (!PresentationController.instance.hasExtendedDisplay) {
    PresentationController.instance.stop();
    AppWindow.setFullScreen(true);
    return;
  }

  final restoreIndex = verses.indexWhere(
    (verse) => verse.verseId == state.restoreVerseId,
  );
  final startIndex = at ?? (restoreIndex < 0 ? 0 : restoreIndex);
  final reference = state.activeChapter?.reference ?? '';
  final title = '${state.activeBible}  ·  $reference';
  PresentationController.instance.present(
    PresentationSession(
      kind: PresentationKind.bible,
      title: title,
      labels: [for (final verse in verses) '${verse.number}'],
      items: [for (final verse in verses) verse.text],
      slide: (slideIndex, screenHeight, style) => PresentationSlide(
        title: title,
        marker: '${verses[slideIndex].number}',
        text: verses[slideIndex].text,
        fontSize: screenHeight * 0.08 * style.scale,
        style: style,
      ),
    ),
    at: startIndex,
  );
}
