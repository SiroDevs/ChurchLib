// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../common/utils/formatting/feedback_messages.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../l10n/gen/app_localizations.dart';
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
      return ProgressView(
        key: ValueKey('seeding'),
        title: l10n.gettingEverythingReady,
        message: l10n.almostThere,
      );
    }

    if (!state.saveActive) return null;

    Widget retrySongs() => FilledButton(
      onPressed: () => bloc.add(const SongsDownloadRetried()),
      child: Text(l10n.retryAction),
    );

    switch (state.songsPhase) {
      case SongsPhase.failed:
        return ProgressView(
          key: const ValueKey('save-failed'),
          isError: true,
          title: l10n.unableDownloadSongs,
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
        message: l10n.percentDownloaded((state.bibleProgress * 100).round()),
        actions: [
          OutlinedButton(
            onPressed: () => bloc.add(const BibleDownloadRestarted()),
            child: Text(l10n.restartAction),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => bloc.add(const BibleDownloadResumed()),
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
            child: Text(l10n.continueAction),
          ),
        ],
      );
    }

    final songsStage =
        state.planSongs &&
        (state.songsPhase == SongsPhase.idle ||
            state.songsPhase == SongsPhase.fetching ||
            state.songsPhase == SongsPhase.saving);
    final String title;
    final String ringLabel;
    final String message;
    if (songsStage) {
      title = state.songsPhase == SongsPhase.saving
          ? l10n.savingYourSongs
          : l10n.fetchingYourSongs;
      ringLabel = state.songsFeedback;
      message = state.songsPhase == SongsPhase.saving ? '' : l10n.momentOnly;
    } else {
      title = l10n.downloadingPrimaryBible;
      ringLabel = l10n.bibleWord;
      message =
          '${state.bibleStep}\n'
          '${l10n.otherBiblesBackground}';
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
