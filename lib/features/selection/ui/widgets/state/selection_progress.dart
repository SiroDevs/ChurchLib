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
    return view ?? const SizedBox.shrink(key: ValueKey('no-progress'));
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

    if (!state.saveActive) return null;

    Widget retrySongs() => FilledButton(
          onPressed: () => bloc.add(const SongsDownloadRetried()),
          child: const Text('Retry'),
        );

    switch (state.songsPhase) {
      case SongsPhase.failed:
        return ProgressView(
          key: const ValueKey('save-failed'),
          isError: true,
          title: 'Unable to download songs',
          message: feedbackMessage(state.songsError, l10n),
          actions: [retrySongs()],
        );
      case SongsPhase.noInternet:
        return ProgressView(
          key: const ValueKey('save-offline'),
          isError: true,
          title: l10n.noConnection,
          message: l10n.noConnectionBody,
          actions: [retrySongs()],
        );
      case SongsPhase.idle:
      case SongsPhase.fetching:
      case SongsPhase.saving:
      case SongsPhase.done:
        break;
    }

    if (state.bibleStatus == BibleStatus.saveFailed) {
      return ProgressView(
        key: const ValueKey('save-failed'),
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
    }

    final songsStage = state.planSongs &&
        (state.songsPhase == SongsPhase.idle ||
            state.songsPhase == SongsPhase.fetching ||
            state.songsPhase == SongsPhase.saving);
    final String title;
    final String ringLabel;
    final String message;
    if (songsStage) {
      title = state.songsPhase == SongsPhase.saving
          ? 'Saving your songs'
          : 'Fetching your songs…';
      ringLabel = state.songsFeedback;
      message = state.songsPhase == SongsPhase.saving
          ? ''
          : 'This only takes a moment';
    } else {
      title = 'Downloading your primary Bible';
      ringLabel = 'Bible';
      message = '${state.bibleStep}\n'
          'Your other Bibles will download in the background.';
    }
    return ProgressView(
      key: const ValueKey('save-progress'),
      title: title,
      ringLabel: ringLabel,
      percent: (state.saveProgress * 100).round(),
      message: message,
    );
  }
}