// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../common/utils/constants/pref_constants.dart';
import '../../../data/models/bible/scripture_item.dart';
import '../../../domain/repos/bible/scripture_repo.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../bible_reader/bloc/reader_cubit.dart';
import '../bloc/scripture_queue_cubit.dart';

/// Ported from biblelib-android's `ScriptureListDetailScreen` /
/// `ScriptureListDetailViewModel`.
class ScriptureListDetailScreen extends StatefulWidget {
  final int listId;
  const ScriptureListDetailScreen({super.key, required this.listId});

  @override
  State<ScriptureListDetailScreen> createState() =>
      _ScriptureListDetailScreenState();
}

class _ScriptureListDetailScreenState extends State<ScriptureListDetailScreen> {
  final _repo = getIt<ScriptureRepo>();
  final _queue = getIt<ScriptureQueueCubit>();
  final _prefs = getIt<PrefRepo>();

  bool _isLoading = true;
  String? _error;
  String _name = '';
  List<ScriptureItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final list = await _repo.getList(widget.listId);
    final items = await _repo.getItems(widget.listId);
    if (!mounted) return;
    if (list == null || items.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'This scripture list could not be found.';
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _name = list.name;
      _items = items;
    });
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename list'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _repo.renameList(widget.listId, result);
      if (mounted) setState(() => _name = result);
    }
  }

  /// Opens this list in the reader, starting at its first scripture, and
  /// activates the floating queue widget.
  void _play() {
    if (_items.isEmpty) return;
    final first = _items.first;
    _queue.open(widget.listId, _name, _items, activeItemId: first.id);
    _prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, first.verseId);
    Navigator.pop(
      context,
      ReaderTarget(
        bibleAbbr: first.bibleAbbr,
        bookId: first.bookId,
        chapterId: first.chapterId,
        verseId: first.verseId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name.isEmpty ? 'Scripture list' : _name),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              tooltip: 'Rename',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _rename,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _body(),
        ),
      ),
      floatingActionButton: (_isLoading || _error != null)
          ? null
          : FloatingActionButton.extended(
              onPressed: _play,
              backgroundColor: ThemeColors.primary,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (_error != null) return Center(child: Text(_error!));
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _items[i];
        return ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
            child: Text(
              '${i + 1}',
              style: const TextStyle(fontSize: 12, color: ThemeColors.primary),
            ),
          ),
          title: Text(item.reference),
          subtitle: Text(
            item.bibleName.isNotEmpty ? item.bibleName : item.bibleAbbr,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}
