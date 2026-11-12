// Flutter imports:
import 'package:flutter/material.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

// Project imports:
import 'common/utils/logging/app_logger.dart';
import 'app.dart';
import 'common/utils/env/environments.dart';
import 'common/utils/env/flavor_config.dart';
import 'core/di/injectable.dart';
import 'core/license/license_cubit.dart';
import 'features/presentation/controller/presentation_platform.dart';

Future<void> main() async {
  if (supportsMultiViewPresentation) {
    enableMultiViewWindowing();
  }
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(
    flavor: Flavor.staging,
    name: 'STG',
    color: Colors.transparent,
    values: const FlavorValues(
      logNetworkInfo: false,
      showFullErrorMessages: false,
    ),
  );
  logger('Starting app from main_stg.dart');
  await configureDependencies(Environments.staging);
  // Reads the stored license (offline, fast). The server check runs in the background.
  await getIt<LicenseCubit>().initialize();
  if (supportsMultiViewPresentation) {
    runMultiApp(
      home: (_, _) => const MyApp(),
      config: MultiAppConfig(
        mainWindowOptions: const WindowOptions(maximize: true),
      ),
    );
  } else {
    runApp(const MyApp());
  }
}
