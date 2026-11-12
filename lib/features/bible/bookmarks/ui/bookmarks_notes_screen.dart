// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/utils/display/dialog_utils.dart';
import '../../../../common/windows/window_frame.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/bible/bible_note.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../home/bible_reader/ui/widgets/dialogs/note_editor_dialog.dart';
import '../bloc/bookmarks_notes_cubit.dart';
import 'widgets/bookmarks_notes_tabs.dart';

class BookmarksNotesScreen extends StatelessWidget {
  final int initialTab;

  const BookmarksNotesScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarksNotesCubit(),
      child: _BookmarksNotesView(initialTab: initialTab),
    );
  }
}

class _BookmarksNotesView extends StatefulWidget {
  final int initialTab;
  const _BookmarksNotesView({required this.initialTab});

  @override
  State<_BookmarksNotesView> createState() => _BookmarksNotesViewState();
}

class _BookmarksNotesViewState extends State<_BookmarksNotesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected(BookmarksNotesState state) async {
    final l10n = AppLocalizations.of(context)!;
    final onBookmarks = _tabController.index == 0;
    final count = onBookmarks
        ? state.selectedBookmarkKeys.length
        : state.selectedNoteKeys.length;
    final ok = await showConfirmDialog(
      context,
      title: l10n.deleteSelectedQuestion,
      message: l10n.deleteSelectedCountMessage(count),
      confirmLabel: l10n.deleteAction,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final cubit = context.read<BookmarksNotesCubit>();
    if (onBookmarks) {
      await cubit.deleteSelectedBookmarks();
    } else {
      await cubit.deleteSelectedNotes();
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final onBookmarks = _tabController.index == 0;
    final ok = await showConfirmDialog(
      context,
      title: onBookmarks
          ? l10n.clearAllBookmarksQuestion
          : l10n.clearAllNotesQuestion,
      message: onBookmarks
          ? l10n.clearBookmarksMessage
          : l10n.clearNotesMessage,
      confirmLabel: l10n.deleteAction,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final cubit = context.read<BookmarksNotesCubit>();
    if (onBookmarks) {
      await cubit.clearAllBookmarks();
    } else {
      await cubit.clearAllNotes();
    }
  }

  void _openInReader(String abbr, String bookId, String chapterId) {
    Navigator.of(
      context,
    ).pop(ReaderTarget(bibleAbbr: abbr, bookId: bookId, chapterId: chapterId));
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
    if (mounted) await context.read<BookmarksNotesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksNotesCubit, BookmarksNotesState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final selectionMode = _tabController.index == 0
            ? state.selectedBookmarkKeys.isNotEmpty
            : state.selectedNoteKeys.isNotEmpty;

        return Scaffold(
          appBar: WindowAppBar(
            icon: Icons.bookmarks_outlined,
            title: l10n.bookmarksNotesTitle,
            bottom: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: ThemeColors.primary,
              indicatorColor: ThemeColors.primary,
              tabs: [
                Tab(text: l10n.bookmarksTab),
                Tab(text: l10n.notesTab),
              ],
            ),
            actions: [
              if (selectionMode)
                IconButton(
                  tooltip: l10n.deleteSelectedTooltip,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteSelected(state),
                )
              else
                IconButton(
                  tooltip: l10n.clearAll,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: _clearAll,
                ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              BookmarksTab(state: state, onOpen: _openInReader),
              NotesTab(state: state, onEdit: _editNote),
            ],
          ).constrained(maxWidth: 720).center(),
        );
      },
    );
  }
}
