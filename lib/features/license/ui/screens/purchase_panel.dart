// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../core/license/license_cubit.dart';
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/license_key_row.dart';
import '../widgets/license_widgets.dart';
import '../widgets/payment_form.dart';
import '../widgets/pending_card.dart';

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

  PayMethod _method = PayMethod.mpesa;
  bool _showKeyBox = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _code.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final outcome = await context.read<LicenseCubit>().submitPayment(
          method: _method == PayMethod.mpesa ? 'mpesa' : 'paypal',
          reference: cleanLicenseCode(_code.text),
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
    final key = cleanLicenseCode(_key.text);
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
        final isMpesa = _method == PayMethod.mpesa;

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
              PendingCard(busy: state.busy, onCheck: _check)
            else ...[
              Text(
                l10n.licenseHowToPay,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              SegmentedButton<PayMethod>(
                segments: const [
                  ButtonSegment(
                    value: PayMethod.mpesa,
                    icon: Icon(Icons.smartphone),
                    label: Text('M-Pesa'),
                  ),
                  ButtonSegment(
                    value: PayMethod.paypal,
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
              PaymentForm(
                formKey: _formKey,
                method: _method,
                code: _code,
                name: _name,
                phone: _phone,
                busy: state.busy,
                onSubmit: _submit,
              ),
            ],
            const SizedBox(height: 18),
            const Divider(),
            TextButton(
              onPressed: () => setState(() => _showKeyBox = !_showKeyBox),
              child: Text(l10n.licenseHaveKey),
            ),
            if (_showKeyBox)
              LicenseKeyRow(
                controller: _key,
                busy: state.busy,
                onRedeem: _redeem,
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
