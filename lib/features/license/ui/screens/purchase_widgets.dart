// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../utils/license_key_utils.dart';
import '../widgets/license_widgets.dart';

/// Payment choices and the reference submission form.
enum PaymentMethod { mpesa, paypal }

/// Form for sending payment details to the license service.
class PurchasePaymentForm extends StatelessWidget {
  const PurchasePaymentForm({
    super.key,
    required this.formKey,
    required this.method,
    required this.pricing,
    required this.nameController,
    required this.phoneController,
    required this.codeController,
    required this.busy,
    required this.onMethodChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final PaymentMethod method;
  final LicensePricing pricing;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController codeController;
  final bool busy;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMpesa = method == PaymentMethod.mpesa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.licenseHowToPay, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<PaymentMethod>(
          segments: const [
            ButtonSegment(
              value: PaymentMethod.mpesa,
              icon: Icon(Icons.smartphone),
              label: Text('M-Pesa'),
            ),
            ButtonSegment(
              value: PaymentMethod.paypal,
              icon: Icon(Icons.payments_outlined),
              label: Text('PayPal'),
            ),
          ],
          selected: {method},
          onSelectionChanged: (selection) => onMethodChanged(selection.first),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.licenseSendTo(
                  isMpesa ? pricing.localPrice : pricing.usdPrice,
                ),
              ),
              CopyValue(
                value: isMpesa ? pricing.mpesaNumber : pricing.paypalEmail,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(l10n.licenseAfterPaying, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: isMpesa
                      ? l10n.licenseCodeMpesa
                      : l10n.licenseCodePaypal,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    RegExp(r'^[A-Z0-9]{8,20}$')
                        .hasMatch(normalizeLicenseInput(value ?? ''))
                    ? null
                    : l10n.licenseCodeInvalid,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.licenseNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().length < 2
                    ? l10n.licenseNameInvalid
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.licensePhoneLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().length < 9
                    ? l10n.licensePhoneInvalid
                    : null,
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
        ),
      ],
    );
  }
}

/// Collapsible field for redeeming a license key.
class LicenseKeyEntry extends StatelessWidget {
  const LicenseKeyEntry({
    super.key,
    required this.controller,
    required this.expanded,
    required this.busy,
    required this.onToggle,
    required this.onRedeem,
  });

  final TextEditingController controller;
  final bool expanded;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(onPressed: onToggle, child: Text(l10n.licenseHaveKey)),
        if (expanded)
          Row(
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
          ),
      ],
    );
  }
}
