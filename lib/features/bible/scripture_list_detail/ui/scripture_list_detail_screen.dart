// Flutter imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/constants/pref_constants.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../cubit/scripture_list_detail_cubit.dart';
import '../../scripture_queue/cubit/scripture_queue_cubit.dart';

class ScriptureListDetailScreen extends StatelessWidget {
  final int listId;
  const ScriptureListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScriptureListDetailCubit(listId),
      child: _ScriptureListDetailView(listId: listId),
    );
  }
}

class _ScriptureListDetailView extends StatelessWidget {
  final int listId;
  const _ScriptureListDetailView({required this.listId});

  Future<void> _rename(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
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
    if (result != null && result.isNotEmpty && context.mounted) {
      await context.read<ScriptureListDetailCubit>().rename(result);
    }
  }

  void _play(BuildContext context, ScriptureListDetailState state) {
    if (state.items.isEmpty) return;
    final first = state.items.first;
    getIt<ScriptureQueueCubit>()
        .open(listId, state.name, state.items, activeItemId: first.id);
    getIt<PrefRepo>()
        .setPrefString(PrefConstants.bibleLastVerseIdKey, first.verseId);
    context.pop(
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
    return BlocBuilder<ScriptureListDetailCubit, ScriptureListDetailState>(
      builder: (context, state) {
        final ready = state.status == ScriptureListDetailStatus.loaded;
        return Scaffold(
          appBar: AppBar(
            title: Text(state.name.isEmpty ? 'Scripture list' : state.name),
            actions: [
              if (ready)
                IconButton(
                  tooltip: 'Rename',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _rename(context, state.name),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _body(state),
            ),
          ),
          floatingActionButton: ready
              ? FloatingActionButton.extended(
                  onPressed: () => _play(context, state),
                  backgroundColor: ThemeColors.primary,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                )
              : null,
        );
      },
    );
  }

  Widget _body(ScriptureListDetailState state) {
    if (state.status == ScriptureListDetailStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.status == ScriptureListDetailStatus.error) {
      return Center(child: Text(state.error!));
    }
    return ListView.separated(
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = state.items[i];
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
