// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../common/constants/app_constants.dart';
import '../../../../common/utils/display/font_utils.dart';
import '../../../../common/utils/formatting/app_util.dart';
import '../../../../common/widgets/presentor/presentor.dart';
import '../../../../data/models/song/songext.dart';
import 'slide_utils.dart';

Future<Map<String, dynamic>> loadSong(SongExt song) async {
  var hasChorus = false;
  List<Tab> tabs = [];
  List<String> labels = [];
  List<String> stanzas = [];

  try {
    var verses = song.content.split("##");
    final int verseCount = verses.length;

    if (song.content.contains("CHORUS")) {
      hasChorus = true;
    }

    if (hasChorus) {
      final String chorus = verses[1].replaceAll("CHORUS#", "");

      labels.add("1");
      labels.add("C");
      stanzas.add(verses[0]);
      stanzas.add(chorus);

      for (int i = 2; i < verseCount; i++) {
        labels.add(i.toString());
        labels.add("C");
        stanzas.add(verses[i]);
        stanzas.add(chorus);
      }
    } else {
      for (int i = 0; i < verseCount; i++) {
        labels.add((i + 1).toString());
        stanzas.add(verses[i]);
      }
    }

    for (final label in labels) {
      tabs.add(
        Tab(
          child: SliderNumbers(label: label, fontSize: 0.5 * .75),
        ),
      );
    }

    return {'tabs': tabs, 'stanzas': stanzas};
  } catch (e) {
    return {'tabs': [], 'stanzas': []};
  }
}

/// One slide per stanza. Each slide may grow to the size its own number of
/// lines allows on a screen [screenHeight] tall (or to [pickedFontSize] when
/// the user chose one), and shrinks only until it fits next to the stanzas of
/// its own kind: verses together, choruses together.
List<Widget> presentorWidgets(
  String title,
  String book,
  double screenHeight,
  List<String> stanzas, {
  double? pickedFontSize,
  bool hasChorus = false,
  ValueChanged<double>? onFontFit,
}) {
  try {
    List<Widget> slides = [];
    for (var i = 0; i < stanzas.length; i++) {
      final stanza = stanzas[i];
      final wanted = pickedFontSize ??
          max(
            12.0,
            calcLinesFontSize(height: screenHeight, lines: lineCountOf(stanza)),
          );
      slides.add(
        SliderContent(
          lyrics: stanza,
          fontSize: wanted,
          fitWith: fitGroupFor(stanzas, i, hasChorus),
          onFontFit: onFontFit,
          onDoubleTap: () => Share.share(
            '${stanza.replaceAll("#", "\n")}\n\n$title,\n$book',
            subject: 'Share verse',
          ),
        ),
      );
    }

    return slides;
  } catch (e) {
    return [];
  }
}

String getSongContent(SongExt song) {
  var songBook = refineTitle(song.songbook);
  var songTitle = songItemTitle(song.songNo, song.title);
  var songContent = song.content.replaceAll("#", "\n");
  return '$songTitle - $songBook\n\n$songContent';
}

Future<void> shareSong(SongExt song) async {
  try {
    Share.share(
      getSongContent(song) + AppConstants.fromApp,
      subject: 'Share the song: ${song.title}',
    );
  } catch (e) {
    logger('Error during sharing song: $e');
  }
}

Future<void> copySong(SongExt song) async {
  try {
    await Clipboard.setData(
      ClipboardData(text: getSongContent(song) + AppConstants.fromApp),
    );
  } catch (e) {
    logger('Error during copying song: $e');
  }
}

Future<void> copyVerse(String songTitle, String songBook, String lyrics) async {
  try {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${lyrics.replaceAll("#", "\n")}'
            '\n\n$songTitle,\n$songBook',
      ),
    );
  } catch (e) {
    logger('Error during copying verse: $e');
  }
}
