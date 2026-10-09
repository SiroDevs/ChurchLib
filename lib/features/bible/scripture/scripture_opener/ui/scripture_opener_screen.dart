// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../common/windows/window_frame.dart';
import '../cubit/scripture_opener_cubit.dart';
import 'widgets/scripture_search_row.dart';

class ScriptureOpenerScreen extends StatelessWidget {
  final String bibleAbbr;
  final String bibleName;

  const ScriptureOpenerScreen({
    super.key,
    required this.bibleAbbr,
    required this.bibleName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScriptureOpenerCubit()..initialize(bibleAbbr, bibleName),
      child: const _ScriptureOpenerView(),
    );
  }
}

class _ScriptureOpenerView extends StatefulWidget {
  const _ScriptureOpenerView();

  @override
  State<_ScriptureOpenerView> createState() => _ScriptureOpenerViewState();
}

class _ScriptureOpenerViewState extends State<_ScriptureOpenerView> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _pop([Object? result]) {
    if (mounted) Navigator.of(context).pop(result);
  }

  Widget _body(BuildContext context, ScriptureOpenerState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.error!, textAlign: TextAlign.center),
        ),
      );
    }

    final cubit = context.read<ScriptureOpenerCubit>();
    final activeKey = state.activeRow?.key;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: state.rows.length,
          itemBuilder: (_, i) {
            final row = state.rows[i];
            return ScriptureSearchRow(
              key: ValueKey(row.key),
              row: row,
              isActive: row.key == activeKey,
              cubit: cubit,
              onOpen: () => _pop(cubit.openScripture(row.key)),
              onQueueAndClose: () async {
                if (await cubit.addToQueueAndClose(row.key)) _pop();
              },
              onQueueAndFinish: () async {
                final target = await cubit.addToQueueAndFinish(row.key);
                if (target != null) _pop(target);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScriptureOpenerCubit, ScriptureOpenerState>(
      listenWhen: (a, b) => a.rows.length != b.rows.length,
      listener: (_, __) => _scrollToEnd(),
      builder: (context, state) => Scaffold(
        appBar: WindowAppBar(
          icon: Icons.auto_stories_outlined,
          title: state.bibleName.isEmpty
              ? 'Scripture Opener'
              : 'Scripture Opener · ${state.bibleName}',
        ),
        body: _body(context, state),
      ),
    );
  }
}
