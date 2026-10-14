import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/state/custom_snackbar.dart';
import '../../../common/windows/window_frame.dart';
import '../../../core/license/license_cubit.dart';
import '../../../core/license/license_models.dart';
import '../../../l10n/app_localizations.dart';
import 'purchase_panel.dart';

/// "Buy license" opened from inside the running app (trial banner, settings).
class PurchaseWindow extends StatelessWidget {
  const PurchaseWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<LicenseCubit, LicenseState>(
      // Close ourselves the moment the license arrives.
      listenWhen: (prev, next) =>
          prev.status != LicenseStatus.licensed &&
          next.status == LicenseStatus.licensed,
      listener: (context, state) {
        CustomSnackbar.show(context, l10n.licenseActivated, isSuccess: true);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: WindowAppBar(
          icon: Icons.verified_outlined,
          title: l10n.licenseUnlock,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const PurchasePanel(),
            ),
          ),
        ),
      ),
    );
  }
}
