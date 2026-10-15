// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/constants/app_assets.dart';
import '../../../../core/license/license_cubit.dart';
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/license_widgets.dart';
import 'purchase_panel.dart';

/// Full-screen page shown instead of the app when ChurchLib may not be used:
/// first launch without internet, trial over, license withdrawn, wrong clock.
/// The router sends the person away as soon as the license is valid again.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LicenseCubit>();
    // Always ask the server first: what is stored here may be out of date
    // (payment approved, trial extended, license reinstated).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(cubit.refresh());
    });
    // While a payment waits for approval, keep checking.
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (cubit.state.paymentPending) unawaited(cubit.refresh());
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: BlocBuilder<LicenseCubit, LicenseState>(
          builder: (context, state) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAssets.iconApp, width: 72, height: 72),
                    const SizedBox(height: 16),
                    _body(context, state, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, LicenseState state, AppLocalizations l10n) {
    final cubit = context.read<LicenseCubit>();
    final retry = FilledButton.icon(
      onPressed: state.busy ? null : () => unawaited(cubit.refresh()),
      icon: const Icon(Icons.refresh),
      label: Text(l10n.licenseRetry),
    );

    switch (state.status) {
      case LicenseStatus.expired:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Heading(
              title: l10n.licenseTrialEndedTitle,
              body: l10n.licenseTrialEndedBody,
            ),
            const SizedBox(height: 8),
            const PurchasePanel(),
          ],
        );

      case LicenseStatus.revoked:
        return _Message(
          icon: Icons.block,
          title: l10n.licenseRevokedTitle,
          body: l10n.licenseRevokedBody,
          actions: [retry, SupportLinks(pricing: state.pricing)],
        );

      case LicenseStatus.clockError:
        return _Message(
          icon: Icons.schedule,
          title: l10n.licenseClockTitle,
          body: l10n.licenseClockBody,
          actions: [retry],
        );

      case LicenseStatus.notConfigured:
        return _Message(
          icon: Icons.settings_suggest_outlined,
          title: l10n.licenseTitle,
          body: l10n.licenseNotConfigured,
          actions: const [],
        );

      case LicenseStatus.unactivated:
        if (state.busy) return _Busy(label: l10n.licenseChecking);
        return _Message(
          icon: Icons.wifi_off_rounded,
          title: l10n.licenseConnectTitle,
          body: state.lastError ?? l10n.licenseConnectBody,
          actions: [retry, SupportLinks(pricing: state.pricing)],
        );

      case LicenseStatus.checking:
      case LicenseStatus.trial:
      case LicenseStatus.licensed:
      case LicenseStatus.developer:
        // Valid (or about to be): the router is moving us on.
        return _Busy(label: l10n.licenseChecking);
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(body, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final action in actions) ...[action, const SizedBox(height: 8)],
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
