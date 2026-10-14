part of 'selection_bloc.dart';

sealed class SelectionEvent {
  const SelectionEvent();
}

class SelectionStarted extends SelectionEvent {
  const SelectionStarted();
}

class ModulesChosen extends SelectionEvent {
  const ModulesChosen({required this.songlib, required this.biblelib});
  final bool songlib;
  final bool biblelib;
}

class ModulesToggled extends SelectionEvent {
  const ModulesToggled({this.songlib, this.biblelib});
  final bool? songlib;
  final bool? biblelib;
}

class SelectionBackPressed extends SelectionEvent {
  const SelectionBackPressed();
}

class BooksRequested extends SelectionEvent {
  const BooksRequested();
}

class BookToggled extends SelectionEvent {
  const BookToggled(this.bookId);
  final int bookId;
}

class BooksConfirmed extends SelectionEvent {
  const BooksConfirmed();
}

class SongsDownloadRetried extends SelectionEvent {
  const SongsDownloadRetried();
}

class BiblesRequested extends SelectionEvent {
  const BiblesRequested();
}

class BibleToggled extends SelectionEvent {
  const BibleToggled(this.abbr);
  final String abbr;
}

class BiblesConfirmed extends SelectionEvent {
  const BiblesConfirmed();
}

class BibleDownloadResumed extends SelectionEvent {
  const BibleDownloadResumed();
}

class BibleDownloadRestarted extends SelectionEvent {
  const BibleDownloadRestarted();
}