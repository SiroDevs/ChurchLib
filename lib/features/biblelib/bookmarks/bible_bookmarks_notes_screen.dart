// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/bible/bible_bookmark.dart';
import '../../../data/models/bible/bible_note.dart';
import '../../../domain/repos/bible/bible_annotation_repo.dart';
import '../../home/bible_reader/bloc/reader_cubit.dart';
import '../../home/bible_reader/ui/reader_dialogs.dart';
import '../../home/bible_reader/ui/verse_row.dart' show parseHexColor;

/// Ported from biblelib-android's bookmark_notes feature: Bookmarks and
/// Notes tabs, each with long-press multi-select and delete, and a tap
/// that opens the verse in the reader (or edits the note for the Notes
/// tab — Android opens the reader there too; editing inline is more
/// useful on desktop, so this differs slightly).
class BibleBookmarksNotesScreen extends StatefulWidget {
  const BibleBookmarksNotesScreen({super.key});

  @override
  State<BibleBookmarksNotesScreen> createState() =>
      _BibleBookmarksNotesScreenState();
}

class _BibleBookmarksNotesScreenState extends State<BibleBookmarksNotesScreen>
    with SingleTickerProviderStateMixin {
  final _repo = getIt<BibleAnnotationRepo>();
  late final TabController _tabController;

  bool _isLoading = true;
  List<BibleBookmark> _bookmarks = [];
  List<BibleNote> _notes = [];
  final Set<String> _selectedBookmarkKeys = {};
  final Set<String> _selectedNoteKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _key(String abbr, String verseId) => '$abbr|$verseId';

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final bookmarks = await _repo.getAllBookmarks();
    final notes = await _repo.getAllNotes();
    if (!mounted) return;
    setState(() {
      _bookmarks = bookmarks;
      _notes = notes;
      _isLoading = false;
    });
  }

  void _toggleBookmark(BibleBookmark b) {
    final key = _key(b.bibleAbbr, b.verseId);
    setState(() {
      if (!_selectedBookmarkKeys.remove(key)) _selectedBookmarkKeys.add(key);
    });
  }

  void _toggleNote(BibleNote n) {
    final key = _key(n.bibleAbbr, n.verseId);
    setState(() {
      if (!_selectedNoteKeys.remove(key)) _selectedNoteKeys.add(key);
    });
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteSelected() async {
    final onBookmarks = _tabController.index == 0;
    final count = onBookmarks
        ? _selectedBookmarkKeys.length
        : _selectedNoteKeys.length;
    final ok = await _confirm(
      'Delete selected?',
      "This will permanently delete $count selected item(s). This can't be undone.",
    );
    if (!ok) return;
    if (onBookmarks) {
      final toDelete = _bookmarks
          .where((b) => _selectedBookmarkKeys.contains(_key(b.bibleAbbr, b.verseId)))
          .toList();
      await _repo.deleteBookmarks(toDelete);
      _selectedBookmarkKeys.clear();
    } else {
      final toDelete = _notes
          .where((n) => _selectedNoteKeys.contains(_key(n.bibleAbbr, n.verseId)))
          .toList();
      await _repo.deleteNotes(toDelete);
      _selectedNoteKeys.clear();
    }
    await _load();
  }

  Future<void> _clearAll() async {
    final onBookmarks = _tabController.index == 0;
    final ok = await _confirm(
      onBookmarks ? 'Clear all bookmarks?' : 'Clear all notes?',
      'This will permanently delete all your ${onBookmarks ? 'bookmarks' : 'notes'} '
      "across every Bible. This can't be undone.",
    );
    if (!ok) return;
    if (onBookmarks) {
      await _repo.deleteBookmarks(_bookmarks);
      _selectedBookmarkKeys.clear();
    } else {
      await _repo.deleteNotes(_notes);
      _selectedNoteKeys.clear();
    }
    await _load();
  }

  void _openInReader(String abbr, String bookId, String chapterId) {
    Navigator.pop(
      context,
      ReaderTarget(bibleAbbr: abbr, bookId: bookId, chapterId: chapterId),
    );
  }

  Future<void> _editNote(BibleNote note) async {
    await showNoteEditor(
      context,
      NotesRequest(
        bibleAbbr: note.bibleAbbr,
        verseId: note.verseId,
        bookId: note.bookId,
        chapterId: note.chapterId,
        title: note.title.isNotEmpty ? note.title : note.verseText,
        verseText: note.verseText,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final selectionMode = _tabController.index == 0
        ? _selectedBookmarkKeys.isNotEmpty
        : _selectedNoteKeys.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks & Notes'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          labelColor: ThemeColors.primary,
          indicatorColor: ThemeColors.primary,
          tabs: const [Tab(text: 'Bookmarks'), Tab(text: 'Notes')],
        ),
        actions: [
          if (selectionMode)
            IconButton(
              tooltip: 'Delete selected',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelected,
            )
          else
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: TabBarView(
            controller: _tabController,
            children: [_bookmarksTab(), _notesTab()],
          ),
        ),
      ),
    );
  }

  Widget _bookmarksTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (_bookmarks.isEmpty) {
      return const Center(
        child: Text(
          'No bookmarks yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    return ListView.separated(
      itemCount: _bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = _bookmarks[i];
        final key = _key(b.bibleAbbr, b.verseId);
        final selected = _selectedBookmarkKeys.contains(key);
        final selectionMode = _selectedBookmarkKeys.isNotEmpty;
        final chapterNumber = b.chapterId.contains('.')
            ? b.chapterId.substring(b.chapterId.indexOf('.') + 1)
            : b.chapterId;
        return ListTile(
          selected: selected,
          selectedTileColor: ThemeColors.primary.withValues(alpha: 0.1),
          leading: Icon(
            Icons.bookmark_rounded,
            color: parseHexColor(b.colorHex) ?? ThemeColors.primary,
          ),
          title: Text('${b.bookId} — $chapterNumber'),
          subtitle: Text(
            b.bibleAbbr.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => selectionMode
              ? _toggleBookmark(b)
              : _openInReader(b.bibleAbbr, b.bookId, b.chapterId),
          onLongPress: () => _toggleBookmark(b),
        );
      },
    );
  }

  Widget _notesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (_notes.isEmpty) {
      return const Center(
        child: Text(
          'No notes yet.',
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    return ListView.separated(
      itemCount: _notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = _notes[i];
        final key = _key(n.bibleAbbr, n.verseId);
        final selected = _selectedNoteKeys.contains(key);
        final selectionMode = _selectedNoteKeys.isNotEmpty;
        return ListTile(
          selected: selected,
          selectedTileColor: ThemeColors.primary.withValues(alpha: 0.1),
          leading: const Icon(Icons.sticky_note_2, color: ThemeColors.primary),
          title: Text(
            n.title.isNotEmpty ? n.title : n.verseText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            n.noteText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => selectionMode ? _toggleNote(n) : _editNote(n),
          onLongPress: () => _toggleNote(n),
        );
      },
    );
  }
}
