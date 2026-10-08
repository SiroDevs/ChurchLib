String refineTitle(String textTitle) {
  return textTitle.replaceAll("''", "'");
}

String refineContent(String contentText) {
  return contentText.replaceAll("''", "'").replaceAll("#", " ");
}

String songItemTitle(int number, String title) {
  if (number != 0) {
    return "$number. ${refineTitle(title)}";
  } else {
    return refineTitle(title);
  }
}

List<String> songVerses(String songContent) {
  List<String> verseList = [];
  var verses = songContent.split("##");

  for (final verse in verses) {
    verseList.add(verse.replaceAll("#", "\n"));
  }
  return verseList;
}

String songCopyString(String title, String content) {
  return "$title\n\n$content";
}

String bookCountString(String title, int count) {
  return '$title ($count)';
}

String lyricsString(String lyrics) {
  return lyrics.replaceAll("#", "\n").replaceAll("''", "'");
}

String songViewerTitle(int number, String title, String alias) {
  String songtitle = "$number. ${refineTitle(title)}";

  if (alias.length > 2 && title != alias) {
    songtitle = "$songtitle (${refineTitle(alias)})";
  }

  return songtitle;
}

String songShareString(String title, String content) {
  return "$title\n\n$content\n\nvia #ChurchLib https://churchlib.vercel.app";
}

String verseOfString(String number, int count) {
  return 'VERSE $number of $count';
}
