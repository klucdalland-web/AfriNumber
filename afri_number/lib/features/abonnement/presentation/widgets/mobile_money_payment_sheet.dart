import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/abonnement_checkout_result.dart';
import 'mobile_money_registry.dart';

/// Requête envoyée à l'API.
class MobileMoneyPaymentRequest {
  const MobileMoneyPaymentRequest({
    required this.countryCode,
    required this.operator,
    required this.phone,
  });

  final String countryCode;
  final MobileMoneyOperator operator;

  /// Numéro normalisé au format local : 0XXXXXXXXX
  final String phone;
}

Future<AbonnementCheckoutResult?> showMobileMoneyPaymentSheet(
  BuildContext context, {
  required String countryCode,
  required String planName,
  String? amountLabel,
  required Future<AbonnementCheckoutResult> Function(
    MobileMoneyPaymentRequest request,
  ) onPay,
}) {
  return showModalBottomSheet<AbonnementCheckoutResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => MobileMoneyPaymentSheet(
      countryCode: countryCode,
      planName: planName,
      amountLabel: amountLabel,
      onPay: onPay,
    ),
  );
}

class MobileMoneyPaymentSheet extends StatefulWidget {
  const MobileMoneyPaymentSheet({
    super.key,
    required this.countryCode,
    required this.planName,
    required this.onPay,
    this.amountLabel,
  });

  final String countryCode;
  final String planName;
  final String? amountLabel;
  final Future<AbonnementCheckoutResult> Function(
    MobileMoneyPaymentRequest request,
  ) onPay;

  @override
  State<MobileMoneyPaymentSheet> createState() =>
      _MobileMoneyPaymentSheetState();
}

class _MobileMoneyPaymentSheetState extends State<MobileMoneyPaymentSheet> {
  final _phoneController = TextEditingController();
  MobileMoneyOperator? _operator;
  String? _error;
  bool _processing = false;

  MobileMoneyCountry? get _country =>
      MobileMoneyRegistry.forCountry(widget.countryCode);

  @override
  void initState() {
    super.initState();
    final ops = _country?.operators ?? const <MobileMoneyOperator>[];
    _operator = ops.isNotEmpty ? ops.first : null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Normalise : retire espaces/tirets/points, convertit +<dial> / <dial> en 0.
  String _normalize(String raw) {
    final country = _country;
    var v = raw.replaceAll(RegExp(r'[\s\-.]'), '');
    if (country == null) return v;

    final dial = country.dialCode.replaceFirst('+', '');
    if (v.startsWith('+$dial')) v = '0${v.substring(dial.length + 1)}';
    if (v.startsWith(dial) &&
        v.length == dial.length + country.localNumberLength - 1) {
      v = '0${v.substring(dial.length)}';
    }
    return v;
  }

  String? _validate(String phone) {
    final country = _country;
    if (country == null || !country.isSupported) {
      return 'abonnement.pay.country_unsupported'.tr;
    }
    if (phone.isEmpty) return 'abonnement.pay.phone_required'.tr;
    if (!country.isValidLocalNumber(phone)) {
      return 'abonnement.pay.phone_invalid'.trParams({
        'hint': country.phoneHint,
      });
    }
    final op = _operator;
    if (op == null) return 'abonnement.pay.operator_required'.tr;
    if (!op.prefixes.any(phone.startsWith)) {
      return 'abonnement.pay.phone_operator_mismatch'.trParams({
        'operator': op.label,
        'prefixes': op.prefixes.join(' / '),
      });
    }
    return null;
  }

  Future<void> _submit() async {
    final country = _country;
    final op = _operator;
    if (country == null || op == null) return;

    final phone = _normalize(_phoneController.text);
    final error = _validate(phone);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _processing = true;
    });

    try {
      final result = await widget.onPay(
        MobileMoneyPaymentRequest(
          countryCode: country.code,
          operator: op,
          phone: phone,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'abonnement.pay.failed'.tr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final country = _country;

    return PopScope(
      canPop: !_processing,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('abonnement.pay.title'.tr,
                  style: AppTextStyles.sectionTitle(22)),
              const SizedBox(height: 4),
              Text(
                widget.amountLabel == null
                    ? widget.planName
                    : '${widget.planName} · ${widget.amountLabel}',
                style:
                    AppTextStyles.body(15, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // ─── Cas pays non supporté ───
              if (country == null || !country.isSupported)
                _UnsupportedCountry(
                  countryCode: widget.countryCode,
                )
              else ...[
                // ── Choix de l'opérateur (dépend du pays) ──
                Text('abonnement.pay.operator'.tr,
                    style: AppTextStyles.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                _OperatorRow(
                  operators: country.operators,
                  selected: _operator,
                  enabled: !_processing,
                  onSelect: (op) => setState(() {
                    _operator = op;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 20),

                // ── Numéro de téléphone ──
                Text('abonnement.pay.phone'.tr,
                    style: AppTextStyles.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  enabled: !_processing,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                    LengthLimitingTextInputFormatter(
                      country.localNumberLength + country.dialCode.length + 2,
                    ),
                  ],
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: country.phoneHint,
                    errorText: _error,
                    errorMaxLines: 2,
                    prefixIcon: Icon(Icons.phone_iphone_rounded,
                        color: colors.onSurfaceVariant),
                    filled: true,
                    fillColor:
                        colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: colors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'abonnement.pay.hint'.tr,
                        style: AppTextStyles.body(13,
                            color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _processing ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _processing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            widget.amountLabel == null
                                ? 'abonnement.pay.confirm'.tr
                                : 'abonnement.pay.confirm_amount'.trParams(
                                    {'amount': widget.amountLabel!},
                                  ),
                          ),
                  ),
                ),
                if (_processing) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'abonnement.pay.waiting'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(13,
                          color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ligne d'opérateurs — gère le wrap si > 3 opérateurs.
class _OperatorRow extends StatelessWidget {
  const _OperatorRow({
    required this.operators,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final List<MobileMoneyOperator> operators;
  final MobileMoneyOperator? selected;
  final bool enabled;
  final ValueChanged<MobileMoneyOperator> onSelect;

  @override
  Widget build(BuildContext context) {
    // Wrap pour supporter 4+ opérateurs (CI, CD…) sur petits écrans.
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final op in operators)
          SizedBox(
            width: (MediaQuery.sizeOf(context).width - 40 - 20) / 3,
            child: _OperatorTile(
              operator: op,
              selected: op.id == selected?.id,
              enabled: enabled,
              onTap: () => onSelect(op),
            ),
          ),
      ],
    );
  }
}

class _OperatorTile extends StatelessWidget {
  const _OperatorTile({
    required this.operator,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final MobileMoneyOperator operator;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? operator.color.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: selected ? operator.color : Colors.transparent,
            width: 1.8,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: operator.color,
              child: Text(
                operator.label[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              operator.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.body(
                12,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc affiché quand aucun opérateur n'est configuré pour le pays.
class _UnsupportedCountry extends StatelessWidget {
  const _UnsupportedCountry({required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.public_off, color: colors.onSurfaceVariant, size: 40),
        const SizedBox(height: 12),
        Text(
          'abonnement.pay.country_unsupported'.trParams({
            'country': countryCode,
          }),
          style: AppTextStyles.body(15, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Text(
          'abonnement.pay.country_unsupported_hint'.tr,
          style: AppTextStyles.body(13, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}