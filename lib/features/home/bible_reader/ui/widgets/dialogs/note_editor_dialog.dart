import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../../../../core/di/injectable.dart';
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../data/models/bible/bible_note.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../../../domain/repos/bible/bible_annotation_repo.dart';

Future<void> showNoteEditor(BuildContext context, NotesRequest request) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _NoteEditorDialog(request: request),
  );
}

class _NoteEditorDialog extends StatefulWidget {
  final NotesRequest request;
  const _NoteEditorDialog({required this.request});

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  final _repo = getIt<BibleAnnotationRepo>();
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saved = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final existing = await _repo.getNote(
      widget.request.bibleAbbr,
      widget.request.verseId,
    );
    if (!mounted) return;
    setState(() {
      _controller.text = existing?.noteText ?? '';
      _loading = false;
      _saved = true;
    });
  }

  Future<void> _save() async {
    final r = widget.request;
    final text = _controller.text;
    if (text.trim().isEmpty) {
      await _repo.deleteNote(r.bibleAbbr, r.verseId);
    } else {
      await _repo.saveNote(
        BibleNote(
          verseId: r.verseId,
          bibleAbbr: r.bibleAbbr,
          bookId: r.bookId,
          chapterId: r.chapterId,
          title: r.title,
          verseText: r.verseText,
          noteText: text,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _close() async {
    await _save();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? CircularProgressIndicator(color: ThemeColors.primary).center()
                .height(160)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        r.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                          .expanded(),
                      IconButton(
                        tooltip: 'Save note',
                        onPressed: _saved ? null : _save,
                        icon: const Icon(Icons.check),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _close,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.verseText)
                      .padding(all: 14)
                      .decorated(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      )
                      .width(double.infinity),
                  const SizedBox(height: 16),
                  const Text(
                    'Your notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 6,
                    maxLines: 12,
                    onChanged: (_) {
                      if (_saved) setState(() => _saved = false);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts on this verse...',
                      border: OutlineInputBorder(),
                    ),
                  )
                      .flexible(),
                ],
              ),
      )
          .constrained(maxWidth: 560, maxHeight: 620),
    );
  }
}
