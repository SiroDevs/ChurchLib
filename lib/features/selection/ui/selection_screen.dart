// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../common/navigator/route_names.dart';
import '../../../common/widgets/theme_button.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/selection_bloc.dart';
import 'steps/bibles_step.dart';
import 'steps/modules_step.dart';
import 'steps/songs_step.dart';
import 'widgets/state/selection_progress.dart';
import 'widgets/steps/step_header.dart';
import 'widgets/steps/step_navigation_bar.dart';

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
              if (current == SelectionStepType.songs)
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: () => bloc.add(const BooksRequested()),
                ),
              const ThemeButton(showLabel: true),
              const SizedBox(width: 12),
            ],
          ),
          bottomNavigationBar: _navigationBar(context, state, onBack),
          body: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
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
                                SelectionStepType.songs =>
                                  const SongsStep(),
                                SelectionStepType.bibles =>
                                  const BiblesStep(),
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

  Widget? _navigationBar(
    BuildContext context,
    SelectionState state,
    VoidCallback? onBack,
  ) {
    if (state.saveActive || state.finishing) return null;
    final bloc = context.read<SelectionBloc>();
    return switch (state.current) {
      SelectionStepType.modules => StepNavigationBar(
          label: 'CONTINUE',
          onBack: onBack,
          onPressed: state.songlib || state.biblelib
              ? () => bloc.add(
                    ModulesChosen(
                      songlib: state.songlib,
                      biblelib: state.biblelib,
                    ),
                  )
              : null,
        ),
      SelectionStepType.songs => StepNavigationBar(
          label: AppLocalizations.of(context)!.proceed.toUpperCase(),
          onBack: onBack,
          onPressed: state.booksStatus == LoadStatus.loaded
              ? () => confirmSongbooks(context, state)
              : null,
        ),
      SelectionStepType.bibles => StepNavigationBar(
          label: 'FINISH',
          onBack: onBack,
          onPressed: state.bibleStatus == BibleStatus.loaded &&
                  state.canProceedBibles
              ? () => bloc.add(const BiblesConfirmed())
              : null,
        ),
      null => null,
    };
  }
}