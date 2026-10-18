// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../l10n/app_localizations.dart';

/// Text field and "Redeem" button for entering a license key.
class LicenseKeyRow extends StatelessWidget {
  const LicenseKeyRow({
    super.key,
    required this.controller,
    required this.busy,
    required this.onRedeem,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.licenseKeyLabel,
              hintText: 'CL-XXXX-XXXX-XXXX',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.tonal(
          onPressed: busy ? null : onRedeem,
          child: Text(l10n.licenseRedeem),
        ),
      ],
    );
  }
}
