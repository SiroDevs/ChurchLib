// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../cubit/scripture_lists_cubit.dart';

class ScriptureListsScreen extends StatelessWidget {
  const ScriptureListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScriptureListsCubit(),
      child: const _ScriptureListsView(),
    );
  }
}

class _ScriptureListsView extends StatelessWidget {
  const _ScriptureListsView();

  Future<void> _delete(BuildContext context, int listId) async {
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
    if (ok == true && context.mounted) {
      await context.read<ScriptureListsCubit>().delete(listId);
    }
  }

  Future<void> _open(BuildContext context, ScriptureListSummary summary) async {
    final target = await context.pushNamed<ReaderTarget>(
      RouteNames.scriptureListDetail,
      pathParameters: {'listId': '${summary.id}'},
    );
    if (target != null && context.mounted) context.pop(target);
    if (context.mounted) await context.read<ScriptureListsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scripture Lists')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: BlocBuilder<ScriptureListsCubit, ScriptureListsState>(
            builder: (context, state) => _body(context, state),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ScriptureListsState state) {
    if (state.status == ScriptureListsStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state.status == ScriptureListsStatus.error) {
      return Center(child: Text(state.error!));
    }
    if (state.lists.isEmpty) {
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
      itemCount: state.lists.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = state.lists[i];
        return ListTile(
          leading: const Icon(Icons.playlist_play, color: ThemeColors.primary),
          title: Text(l.name),
          subtitle: Text(
            '${l.itemCount} scripture(s) · ${fmt.format(DateTime.fromMillisecondsSinceEpoch(l.createdAt))}',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => _open(context, l),
          trailing: IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, l.id),
          ),
        );
      },
    );
  }
}
