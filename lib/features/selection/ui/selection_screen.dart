// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../common/navigator/route_names.dart';
import '../../../common/widgets/theme_button.dart';
import '../bloc/selection_bloc.dart';
import 'steps/bibles_step.dart';
import 'steps/modules_step.dart';
import 'widgets/state/selection_progress.dart';
import 'steps/songbooks_step.dart';
import 'widgets/steps/step_header.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key, this.only});

  final SelectionStepType? only;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectionBloc(only: only)..add(const SelectionStarted()),
      child: const _SelectionView(),
    );
  }
}

class _SelectionView extends StatelessWidget {
  const _SelectionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectionBloc, SelectionState>(
      listenWhen: (p, c) => !p.finishing && c.finishing,
      listener: (context, state) async {
        await Future.delayed(const Duration(milliseconds: 900));
        if (!context.mounted) return;
        context.goNamed(RouteNames.main);
      },
      builder: (context, state) {
        final bloc = context.read<SelectionBloc>();
        final onBack = state.canGoBack
            ? () => bloc.add(const SelectionBackPressed())
            : null;
        final current = state.current;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Set up ChurchLib'),
            actions: [
              if (current == SelectionStepType.songbooks)
                Tooltip(
                  message: 'Refresh books data',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => bloc.add(const BooksRequested()),
                  ),
                ),
              const ThemeButton(),
              const SizedBox(width: 20),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      children: [
                        if (state.steps.length > 1) StepHeader(flow: state),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: KeyedSubtree(
                              key: ValueKey(current),
                              child: switch (current) {
                                SelectionStepType.modules =>
                                  const ModulesStep(),
                                SelectionStepType.songbooks =>
                                  SongbooksStep(onBack: onBack),
                                SelectionStepType.bibles =>
                                  BiblesStep(onBack: onBack),
                                null => const SizedBox.shrink(),
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: SelectionProgress()),
            ],
          ),
        );
      },
    );
  }
}
