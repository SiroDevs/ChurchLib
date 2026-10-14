import 'package:flutter/material.dart';

import 'app.dart';
import 'common/utils/formatting/app_util.dart';
import 'common/utils/display/app_window.dart';
import 'common/utils/env/environments.dart';
import 'common/utils/env/flavor_config.dart';
import 'core/di/injectable.dart';
import 'core/license/license_cubit.dart';

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
  // Reads the stored license (offline, fast). The server check runs in the background.
  await getIt<LicenseCubit>().initialize();
  await AppWindow.showMaximized();
  runApp(const MyApp());
}
