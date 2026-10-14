import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/state/custom_snackbar.dart';
import '../../../core/license/license_cubit.dart';
import '../../../core/license/license_models.dart';
import '../../../l10n/app_localizations.dart';
import 'license_widgets.dart';

enum _PayMethod { mpesa, paypal }

/// Price, how to pay, the form for the transaction code, and the license-key
/// box. Used by the blocking paywall screen and by the "Buy license" window.
class PurchasePanel extends StatefulWidget {
  const PurchasePanel({super.key});

  @override
  State<PurchasePanel> createState() => _PurchasePanelState();
}

class _PurchasePanelState extends State<PurchasePanel> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _key = TextEditingController();

  _PayMethod _method = _PayMethod.mpesa;
  bool _showKeyBox = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _code.dispose();
    _key.dispose();
    super.dispose();
  }

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s'), '').toUpperCase();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final outcome = await context.read<LicenseCubit>().submitPayment(
          method: _method == _PayMethod.mpesa ? 'mpesa' : 'paypal',
          reference: _clean(_code.text),
          payerName: _name.text.trim(),
          payerPhone: _phone.text.trim(),
        );
    if (!mounted || outcome.ok) return;
    CustomSnackbar.show(context, outcome.message ?? '');
  }

  Future<void> _check() async {
    final outcome = await context.read<LicenseCubit>().refresh();
    if (!mounted || outcome.ok) return;
    CustomSnackbar.show(context, outcome.message ?? '');
  }

  Future<void> _redeem() async {
    final l10n = AppLocalizations.of(context)!;
    final key = _clean(_key.text);
    if (key.length < 8) return;
    final outcome = await context.read<LicenseCubit>().redeem(key);
    if (!mounted) return;
    CustomSnackbar.show(
      context,
      outcome.ok ? l10n.licenseActivated : (outcome.message ?? ''),
      isSuccess: outcome.ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<LicenseCubit, LicenseState>(
      builder: (context, state) {
        final pricing = state.pricing;
        final isMpesa = _method == _PayMethod.mpesa;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              l10n.licensePriceLine(pricing.localPrice, pricing.usdPrice),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            if (state.paymentPending)
              _PendingCard(busy: state.busy, onCheck: _check)
            else ...[
              Text(
                l10n.licenseHowToPay,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              SegmentedButton<_PayMethod>(
                segments: const [
                  ButtonSegment(
                    value: _PayMethod.mpesa,
                    icon: Icon(Icons.smartphone),
                    label: Text('M-Pesa'),
                  ),
                  ButtonSegment(
                    value: _PayMethod.paypal,
                    icon: Icon(Icons.payments_outlined),
                    label: Text('PayPal'),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (selection) =>
                    setState(() => _method = selection.first),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.licenseSendTo(
                      isMpesa ? pricing.localPrice : pricing.usdPrice,
                    )),
                    CopyValue(
                      value: isMpesa ? pricing.mpesaNumber : pricing.paypalEmail,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(l10n.licenseAfterPaying, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText:
                            isMpesa ? l10n.licenseCodeMpesa : l10n.licenseCodePaypal,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          RegExp(r'^[A-Z0-9]{8,20}$').hasMatch(_clean(v ?? ''))
                              ? null
                              : l10n.licenseCodeInvalid,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.licenseNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').trim().length < 2
                          ? l10n.licenseNameInvalid
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.licensePhoneLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').trim().length < 9
                          ? l10n.licensePhoneInvalid
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: state.busy ? null : _submit,
                        child: Text(l10n.licenseSubmitPayment),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Divider(),
            TextButton(
              onPressed: () => setState(() => _showKeyBox = !_showKeyBox),
              child: Text(l10n.licenseHaveKey),
            ),
            if (_showKeyBox)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _key,
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
                    onPressed: state.busy ? null : _redeem,
                    child: Text(l10n.licenseRedeem),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('${l10n.licenseComputerId}: ',
                    style: theme.textTheme.bodySmall),
                CopyValue(
                  value: state.computerId,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SupportLinks(pricing: pricing),
          ],
        );
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.busy, required this.onCheck});

  final bool busy;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.licensePaymentPendingTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.licensePaymentPendingBody),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy ? null : onCheck,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.licenseCheckAgain),
          ),
        ],
      ),
    );
  }
}
