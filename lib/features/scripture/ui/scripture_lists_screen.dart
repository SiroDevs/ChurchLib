// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../common/navigator/route_names.dart';
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../domain/repos/bible/scripture_repo.dart';
import '../../home/bible_reader/bloc/reader_cubit.dart';

class _ListSummary {
  final int id;
  final String name;
  final int createdAt;
  final int itemCount;
  _ListSummary(this.id, this.name, this.createdAt, this.itemCount);
}

/// Ported from biblelib-android's `ScriptureListScreen` /
/// `ScriptureListsViewModel`.
class ScriptureListsScreen extends StatefulWidget {
  const ScriptureListsScreen({super.key});

  @override
  State<ScriptureListsScreen> createState() => _ScriptureListsScreenState();
}

class _ScriptureListsScreenState extends State<ScriptureListsScreen> {
  final _repo = getIt<ScriptureRepo>();
  bool _isLoading = true;
  String? _error;
  List<_ListSummary> _lists = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lists = await _repo.getAllLists();
      final summaries = <_ListSummary>[];
      for (final l in lists) {
        final count = await _repo.getItemCount(l.id!);
        summaries.add(_ListSummary(l.id!, l.name, l.createdAt, count));
      }
      if (!mounted) return;
      setState(() {
        _lists = summaries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load scripture lists.';
      });
    }
  }

  Future<void> _delete(int listId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this list?'),
        content: const Text("This can't be undone."),
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
    if (ok == true) {
      await _repo.deleteList(listId);
      await _load();
    }
  }

  Future<void> _open(_ListSummary summary) async {
    final target = await context.pushNamed<ReaderTarget>(
      RouteNames.scriptureListDetail,
      pathParameters: {'listId': '${summary.id}'},
    );
    if (target != null && mounted) context.pop(target);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scripture Lists')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _body(),
        ),
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
    if (_lists.isEmpty) {
      return const Center(
        child: Text(
          'No saved scripture lists yet.\nBuild one in Scripture Opener.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ThemeColors.mediumGrey),
        ),
      );
    }
    final fmt = DateFormat('MMM d, yyyy');
    return ListView.separated(
      itemCount: _lists.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = _lists[i];
        return ListTile(
          leading: const Icon(Icons.playlist_play, color: ThemeColors.primary),
          title: Text(l.name),
          subtitle: Text(
            '${l.itemCount} scripture(s) · ${fmt.format(DateTime.fromMillisecondsSinceEpoch(l.createdAt))}',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => _open(l),
          trailing: IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(l.id),
          ),
        );
      },
    );
  }
}
