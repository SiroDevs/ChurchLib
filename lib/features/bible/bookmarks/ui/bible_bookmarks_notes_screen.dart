// Flutter imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/bible/bible_note.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../home/bible_reader/ui/widgets/dialogs/note_editor_dialog.dart';
import '../bloc/bible_bookmarks_notes_cubit.dart';
import 'widgets/bookmarks_notes_tabs.dart';

class BibleBookmarksNotesScreen extends StatelessWidget {
  const BibleBookmarksNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleBookmarksNotesCubit(),
      child: const _BibleBookmarksNotesView(),
    );
  }
}

class _BibleBookmarksNotesView extends StatefulWidget {
  const _BibleBookmarksNotesView();

  @override
  State<_BibleBookmarksNotesView> createState() =>
      _BibleBookmarksNotesViewState();
}

class _BibleBookmarksNotesViewState extends State<_BibleBookmarksNotesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _deleteSelected(BibleBookmarksNotesState state) async {
    final onBookmarks = _tabController.index == 0;
    final count = onBookmarks
        ? state.selectedBookmarkKeys.length
        : state.selectedNoteKeys.length;
    final ok = await _confirm(
      'Delete selected?',
      "This will permanently delete $count selected item(s). This can't be undone.",
    );
    if (!ok || !mounted) return;
    final cubit = context.read<BibleBookmarksNotesCubit>();
    if (onBookmarks) {
      await cubit.deleteSelectedBookmarks();
    } else {
      await cubit.deleteSelectedNotes();
    }
  }

  Future<void> _clearAll() async {
    final onBookmarks = _tabController.index == 0;
    final ok = await _confirm(
      onBookmarks ? 'Clear all bookmarks?' : 'Clear all notes?',
      'This will permanently delete all your ${onBookmarks ? 'bookmarks' : 'notes'} '
      "across every Bible. This can't be undone.",
    );
    if (!ok || !mounted) return;
    final cubit = context.read<BibleBookmarksNotesCubit>();
    if (onBookmarks) {
      await cubit.clearAllBookmarks();
    } else {
      await cubit.clearAllNotes();
    }
  }

  void _openInReader(String abbr, String bookId, String chapterId) {
    context.pop(
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
    if (mounted) await context.read<BibleBookmarksNotesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleBookmarksNotesCubit, BibleBookmarksNotesState>(
      builder: (context, state) {
        final selectionMode = _tabController.index == 0
            ? state.selectedBookmarkKeys.isNotEmpty
            : state.selectedNoteKeys.isNotEmpty;

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
                  onPressed: () => _deleteSelected(state),
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
                children: [
                  BookmarksTab(state: state, onOpen: _openInReader),
                  NotesTab(state: state, onEdit: _editNote),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
