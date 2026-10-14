import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'license_api.dart';
import 'license_config.dart';
import 'license_cubit.dart';
import 'license_service.dart';
import 'license_storage.dart';
import 'license_verifier.dart';
import 'machine_id.dart';

/// Registers the license feature by hand, so no code generation
/// (`build_runner`) is needed for it.
void registerLicenseDependencies(GetIt getIt) {
  if (getIt.isRegistered<LicenseCubit>()) return;
  final prefs = getIt<SharedPreferences>();
  getIt.registerSingleton<LicenseCubit>(
    LicenseCubit(
      LicenseService(
        api: LicenseApi(),
        storage: LicenseStorage(prefs),
        machineId: MachineIdProvider(prefs),
        verifier: LicenseTokenVerifier(LicenseConfig.publicKeyBase64),
      ),
    ),
  );
}
