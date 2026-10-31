// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../common/constants/app_constants.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// "1 day left" / "5 days left"
String daysLeftLabel(AppLocalizations l10n, int days) =>
    days == 1 ? l10n.licenseDayLeft : l10n.licenseDaysLeft('$days');

/// A value (phone number, license key...) with a button that copies it.
class CopyValue extends StatelessWidget {
  const CopyValue({super.key, required this.value, this.style});

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: SelectableText(value, style: style)),
        IconButton(
          tooltip: l10n.licenseCopy,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copy_rounded, size: 18),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            CustomSnackbar.show(
              context,
              l10n.licenseCopied,
              isSuccess: true,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
    );
  }
}

/// Email / WhatsApp links to the person who sells ChurchLib.
class SupportLinks extends StatelessWidget {
  const SupportLinks({super.key, required this.pricing});

  final LicensePricing pricing;

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final whatsapp = pricing.supportWhatsapp.replaceAll(RegExp(r'\D'), '');
    final hasEmail = pricing.supportEmail.isNotEmpty;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(l10n.licenseSupport),
        if (whatsapp.isNotEmpty)
          TextButton(
            onPressed: () => _open('https://wa.me/$whatsapp'),
            child: const Text('WhatsApp'),
          ),
        if (hasEmail)
          TextButton(
            onPressed: () => _open('mailto:${pricing.supportEmail}'),
            child: Text(pricing.supportEmail),
          ),
        if (whatsapp.isEmpty && !hasEmail)
          TextButton(
            onPressed: () => _open(AppConstants.siteLink),
            child: const Text('sirodevs.com/churchlib'),
          ),
      ],
    );
  }
}
