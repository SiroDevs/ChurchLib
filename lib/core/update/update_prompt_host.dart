// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../common/constants/pref_constants.dart';
import '../../domain/repos/pref_repo.dart';
import '../../l10n/gen/app_localizations.dart';
import 'update_cubit.dart';
import 'update_installer.dart';
import 'update_release.dart';
import 'update_service.dart';

/// Checks for releases and presents downloaded updates to the user.
class UpdatePromptHost extends StatefulWidget {
  const UpdatePromptHost({
    super.key,
    required this.child,
    required this.cubit,
    required this.preferences,
    required this.service,
  });

  final Widget child;
  final UpdateCubit cubit;
  final PrefRepo preferences;
  final UpdateService service;

  @override
  State<UpdatePromptHost> createState() => _UpdatePromptHostState();
}

/// Coordinates release notifications and installer prompts.
class _UpdatePromptHostState extends State<UpdatePromptHost> {
  late Future<void> _initialization;
  bool _initializationStarted = false;
  bool _processingUpdate = false;
  String? _installRequestedVersion;

  /// Initializes desktop notifications and starts the initial release check.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializationStarted) return;
    _initializationStarted = true;
    _initialization = _initializeNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.cubit.start();
    });
  }

  /// Prepares the localized action label used by desktop notifications.
  Future<void> _initializeNotifications() async {
    if (!_isDesktop) return;
    try {
      await widget.service.initialize(
        AppLocalizations.of(context)!.updateOpenReleaseAction,
      );
    } on Object {
      // Update checks remain available when desktop notifications are disabled.
    }
  }

  /// Connects update state changes to the update prompt flow.
  @override
  Widget build(BuildContext context) => BlocListener<UpdateCubit, UpdateState>(
    bloc: widget.cubit,
    listenWhen: (previous, current) =>
        previous.checkSequence != current.checkSequence,
    listener: (context, state) => _processUpdate(state),
    child: widget.child,
  );

  /// Chooses between a verified download prompt and a desktop notification.
  Future<void> _processUpdate(UpdateState state) async {
    if (!_isDesktop || !state.hasUpdate || _processingUpdate || !mounted)
      return;
    _processingUpdate = true;
    try {
      await _initialization;
      if (!mounted) return;
      final update = _downloadableRelease(state);
      if (_autoDownloadEnabled) {
        if (update == null) {
          await _notifyIfNew(state);
        } else {
          await _downloadAndPrompt(update);
        }
      } else {
        await _notifyIfNew(state);
      }
    } on Object {
      // The next scheduled check retries network and download failures.
    } finally {
      _processingUpdate = false;
    }
  }

  bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  bool get _autoDownloadEnabled {
    return widget.preferences.getAutoDownloadUpdates();
  }

  /// Builds an installer download request from the latest release state.
  UpdateRelease? _downloadableRelease(UpdateState state) {
    if (state.fileName.isEmpty || state.checksumUrl.isEmpty) return null;
    return UpdateRelease(
      version: state.latest,
      releaseUrl: state.releaseUrl,
      assetName: state.fileName,
      assetUrl: state.downloadUrl,
      checksumUrl: state.checksumUrl,
    );
  }

  /// Downloads the installer and asks whether to open it.
  Future<void> _downloadAndPrompt(UpdateRelease update) async {
    if (_installRequestedVersion == update.version) return;
    if (widget.preferences.getPrefString(PrefConstants.dismissedUpdateKey) ==
        update.version) {
      return;
    }
    late final File installer;
    try {
      installer = await widget.service.download(update);
    } on Object {
      if (!mounted) return;
      await _showMessage(
        AppLocalizations.of(context)!.updateNotificationTitle,
        AppLocalizations.of(context)!.updateDownloadFailed,
      );
      return;
    }
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final shouldInstall = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.updateInstallTitle),
        content: Text(l10n.updateInstallBody(update.version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.updateLaterAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.updateInstallAction),
          ),
        ],
      ),
    );
    if (shouldInstall != true) {
      widget.preferences.setPrefString(
        PrefConstants.dismissedUpdateKey,
        update.version,
      );
      return;
    }
    try {
      await UpdateInstaller.open(installer);
      _installRequestedVersion = update.version;
    } on Object {
      if (mounted)
        await _showMessage(l10n.updateInstallTitle, l10n.updateInstallerFailed);
    }
  }

  /// Sends one desktop notification for each newly available version.
  Future<void> _notifyIfNew(UpdateState state) async {
    final key = PrefConstants.lastNotifiedUpdateKey;
    if (widget.preferences.getPrefString(key) == state.latest) return;
    final l10n = AppLocalizations.of(context)!;
    await widget.service.showNotification(
      l10n.updateNotificationTitle,
      l10n.updateNotificationBody(state.latest),
      state.releaseUrl,
    );
    widget.preferences.setPrefString(key, state.latest);
  }

  /// Shows a localized update error dialog.
  Future<void> _showMessage(String title, String message) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(AppLocalizations.of(dialogContext)!.updateLaterAction),
        ),
      ],
    ),
  );
}
