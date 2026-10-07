// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../common/utils/app_util.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../bloc/selection_bloc.dart';
import 'progress_view.dart';

class SelectionProgress extends StatelessWidget {
  const SelectionProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SelectionBloc>().state;
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<SelectionBloc>();

    final view = _viewFor(state, bloc, l10n);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: view ?? const SizedBox.shrink(key: ValueKey('no-progress')),
    );
  }

  Widget? _viewFor(
    SelectionState state,
    SelectionBloc bloc,
    AppLocalizations l10n,
  ) {
    if (state.finishing) {
      return const ProgressView(
        key: ValueKey('seeding'),
        title: 'Getting everything ready…',
        message: 'Almost there',
      );
    }

    Widget retrySongs() => FilledButton(
          onPressed: () => bloc.add(const SongsDownloadRetried()),
          child: const Text('Retry'),
        );

    switch (state.songsPhase) {
      case SongsPhase.fetching:
        return const ProgressView(
          key: ValueKey('songs-fetching'),
          title: 'Fetching your songs…',
          message: 'This only takes a moment',
        );
      case SongsPhase.saving:
        return ProgressView(
          key: const ValueKey('songs-saving'),
          title: 'Saving your songs',
          percent: state.songsProgress,
          ringLabel: state.songsFeedback,
        );
      case SongsPhase.failed:
        return ProgressView(
          key: const ValueKey('songs-failed'),
          isError: true,
          title: 'Unable to download songs',
          message: feedbackMessage(state.songsError, l10n),
          actions: [retrySongs()],
        );
      case SongsPhase.noInternet:
        return ProgressView(
          key: const ValueKey('songs-offline'),
          isError: true,
          title: l10n.noConnection,
          message: l10n.noConnectionBody,
          actions: [retrySongs()],
        );
      case SongsPhase.idle:
      case SongsPhase.done:
        break;
    }

    switch (state.bibleStatus) {
      case BibleStatus.saving:
        return ProgressView(
          key: const ValueKey('bible-saving'),
          title: 'Downloading your primary Bible',
          ringLabel: 'Bible',
          percent: (state.bibleProgress * 100).round(),
          message: '${state.bibleStep}\n'
              'Your other Bibles will download in the background.',
        );
      case BibleStatus.saveFailed:
        return ProgressView(
          key: const ValueKey('bible-failed'),
          isError: true,
          title: state.bibleMessage,
          message: '${(state.bibleProgress * 100).round()}% downloaded',
          actions: [
            OutlinedButton(
              onPressed: () => bloc.add(const BibleDownloadRestarted()),
              child: const Text('Restart'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => bloc.add(const BibleDownloadResumed()),
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      case BibleStatus.loading:
      case BibleStatus.loaded:
      case BibleStatus.error:
      case BibleStatus.saved:
        return null;
    }
  }
}
