// Flutter imports:
import 'package:flutter/material.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;

// Project imports:
import 'app.dart';
import 'common/utils/display/app_window.dart';
import 'common/utils/env/environments.dart';
import 'common/utils/env/flavor_config.dart';
import 'common/utils/formatting/app_util.dart';
import 'core/di/injectable.dart';
import 'core/license/license_cubit.dart';
import 'features/presentation/presentation_controller.dart';

Future<void> main() async {
  // ignore: invalid_use_of_internal_member
  isWindowingEnabled = true;
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
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => PresentationController.instance.init(),
  );
}
