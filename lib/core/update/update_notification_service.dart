// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import '../../common/constants/app_constants.dart';

/// Shows update availability through the desktop notification service.
class UpdateNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Prepares operating-system notification support.
  Future<void> initialize(String openReleaseAction) async {
    final initialization = InitializationSettings(
      linux: LinuxInitializationSettings(defaultActionName: openReleaseAction),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      windows: WindowsInitializationSettings(
        appName: AppConstants.appTitle,
        appUserModelId: AppConstants.windowsAppUserModelId,
        guid: '51d3d17d-7022-4ab0-991f-1603cd9fc5d3',
      ),
    );
    await _plugin.initialize(
      settings: initialization,
      onDidReceiveNotificationResponse: _openReleaseFromNotification,
    );
  }

  /// Shows one desktop notification for an available version.
  Future<void> show(String title, String body, String releaseUrl) async {
    if (Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: false);
    }
    await _plugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        linux: LinuxNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
      payload: releaseUrl,
    );
  }

  /// Opens only secure GitHub release links from notification actions.
  void _openReleaseFromNotification(NotificationResponse response) {
    final uri = Uri.tryParse(response.payload ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host != 'github.com') {
      return;
    }
    final command = Platform.isWindows
        ? 'explorer.exe'
        : Platform.isMacOS
        ? 'open'
        : 'xdg-open';
    unawaited(_launch(command, uri.toString()));
  }

  /// Launches a URL through the operating system handler.
  Future<void> _launch(String command, String url) async {
    try {
      await Process.start(command, [url], mode: ProcessStartMode.detached);
    } on ProcessException {
      // External link handling is unavailable.
    }
  }
}
