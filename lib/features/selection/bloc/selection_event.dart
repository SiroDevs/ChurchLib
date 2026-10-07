part of 'selection_bloc.dart';

sealed class SelectionEvent {
  const SelectionEvent();
}

/// Sent once when the screen opens; resumes an interrupted songs download.
class SelectionStarted extends SelectionEvent {
  const SelectionStarted();
}

// ── Step 1: apps ───────────────────────────────────────────────────────────
class ModulesChosen extends SelectionEvent {
  const ModulesChosen({required this.songlib, required this.biblelib});
  final bool songlib;
  final bool biblelib;
}

class SelectionBackPressed extends SelectionEvent {
  const SelectionBackPressed();
}

// ── Songbooks step ─────────────────────────────────────────────────────────
class BooksRequested extends SelectionEvent {
  const BooksRequested();
}

class BookToggled extends SelectionEvent {
  const BookToggled(this.bookId);
  final int bookId;
}

/// Save the ticked songbooks, then download their songs.
class BooksConfirmed extends SelectionEvent {
  const BooksConfirmed();
}

class SongsDownloadRetried extends SelectionEvent {
  const SongsDownloadRetried();
}

// ── Bibles step ────────────────────────────────────────────────────────────
class BiblesRequested extends SelectionEvent {
  const BiblesRequested();
}

class BibleToggled extends SelectionEvent {
  const BibleToggled(this.abbr);
  final String abbr;
}

/// Save the selection and download the primary translation.
class BiblesConfirmed extends SelectionEvent {
  const BiblesConfirmed();
}

/// Resume the primary download from where it stopped.
class BibleDownloadResumed extends SelectionEvent {
  const BibleDownloadResumed();
}

/// Clear the primary's partial content and download it again.
class BibleDownloadRestarted extends SelectionEvent {
  const BibleDownloadRestarted();
}
