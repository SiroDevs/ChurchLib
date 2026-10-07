// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app.dart';
import 'common/utils/app_util.dart';
import 'common/utils/app_window.dart';
import 'common/utils/env/environments.dart';
import 'common/utils/env/flavor_config.dart';
import 'core/di/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    flavor: Flavor.production,
    name: 'PROD',
    color: Colors.transparent,
    values: const FlavorValues(
      logNetworkInfo: false,
      showFullErrorMessages: false,
    ),
  );
  logger('Starting app from main.dart');
  await configureDependencies(Environments.production);
  await AppWindow.showMaximized();
  runApp(const MyApp());
}
