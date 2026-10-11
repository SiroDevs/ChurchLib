import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../common/utils/display/dialog_utils.dart';
import '../../../../../common/windows/open_windows.dart';
import '../../../../../common/windows/window_frame.dart';
import '../../../../../core/theme/theme_colors.dart';
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
    final ok = await showConfirmDialog(
      context,
      title: 'Delete this list?',
      message: "This can't be undone.",
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok && context.mounted) {
      await context.read<ScriptureListsCubit>().delete(listId);
    }
  }

  Future<void> _open(BuildContext context, ScriptureListSummary summary) async {
    final target = await openScriptureListDetail(context, summary.id);
    if (target != null && context.mounted) Navigator.of(context).pop(target);
    if (context.mounted) await context.read<ScriptureListsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WindowAppBar(
        icon: Icons.list_alt,
        title: 'Scripture Lists',
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: BlocBuilder<ScriptureListsCubit, ScriptureListsState>(
          builder: (context, state) => _body(context, state),
        ),
      )
          .center(),
    );
  }

  Widget _body(BuildContext context, ScriptureListsState state) {
    if (state.status == ScriptureListsStatus.loading) {
      return CircularProgressIndicator(color: ThemeColors.primary).center();
    }
    if (state.status == ScriptureListsStatus.error) {
      return Text(state.error!).center();
    }
    if (state.lists.isEmpty) {
      return Text(
        'No saved scripture lists yet.\nBuild one in Scripture Opener.',
        textAlign: TextAlign.center,
        style: TextStyle(color: ThemeColors.mediumGrey),
      )
          .center();
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
