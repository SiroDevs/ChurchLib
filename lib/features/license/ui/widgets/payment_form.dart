// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../l10n/app_localizations.dart';

enum PayMethod { mpesa, paypal }

/// Upper-cases a transaction code or license key and strips whitespace.
String cleanLicenseCode(String value) =>
    value.replaceAll(RegExp(r'\s'), '').toUpperCase();

/// Transaction code, name and phone fields plus the submit button.
/// The parent owns the controllers and the form key so the typed values
/// survive while this form is hidden.
class PaymentForm extends StatelessWidget {
  const PaymentForm({
    super.key,
    required this.formKey,
    required this.method,
    required this.code,
    required this.name,
    required this.phone,
    required this.busy,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final PayMethod method;
  final TextEditingController code;
  final TextEditingController name;
  final TextEditingController phone;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMpesa = method == PayMethod.mpesa;

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: code,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: isMpesa ? l10n.licenseCodeMpesa : l10n.licenseCodePaypal,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                RegExp(r'^[A-Z0-9]{8,20}$').hasMatch(cleanLicenseCode(v ?? ''))
                ? null
                : l10n.licenseCodeInvalid,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.licenseNameLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? l10n.licenseNameInvalid : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.licensePhoneLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v ?? '').trim().length < 9 ? l10n.licensePhoneInvalid : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: busy ? null : onSubmit,
              child: Text(l10n.licenseSubmitPayment),
            ),
          ),
        ],
      ),
    );
  }
}
