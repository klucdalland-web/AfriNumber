import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/number_purchase_remote_data_source.dart';
import '../../domain/models/country_item.dart';
import '../../domain/models/number_offer.dart';

enum _NumberFilter { mobile, fixed, free }

class NumberPurchasePage extends StatefulWidget {
  const NumberPurchasePage({
    super.key,
    required this.initialCountry,
    required this.countries,
  });

  final CountryItem initialCountry;
  final List<CountryItem> countries;

  @override
  State<NumberPurchasePage> createState() => _NumberPurchasePageState();
}

class _NumberPurchasePageState extends State<NumberPurchasePage> {
  late CountryItem _country = widget.initialCountry;
  List<NumberOffer> _offers = const [];
  _NumberFilter _filter = _NumberFilter.mobile;
  String? _selectedNumber;
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _hasError = false;
  int _loadRequest = 0;

  NumberPurchaseRemoteDataSource get _dataSource =>
      NumberPurchaseRemoteDataSource(Get.find<DioClient>());

  List<NumberOffer> get _filteredOffers => _offers.where((offer) {
    return switch (_filter) {
      _NumberFilter.mobile => offer.type == 'mobile',
      _NumberFilter.fixed => offer.type == 'fixed',
      _NumberFilter.free => offer.type == 'free',
    };
  }).toList();

  NumberOffer? get _selectedOffer {
    for (final offer in _filteredOffers) {
      if (offer.phoneNumber == _selectedNumber) return offer;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final request = ++_loadRequest;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final offers = await _dataSource.searchAvailableNumbers(_country.code);
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _offers = offers;
        _isLoading = false;
        _selectedNumber = _firstOfferFor(_filter, offers)?.phoneNumber;
      });
    } catch (_) {
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _offers = const [];
        _selectedNumber = null;
      });
    }
  }

  NumberOffer? _firstOfferFor(_NumberFilter filter, List<NumberOffer> offers) {
    final type = switch (filter) {
      _NumberFilter.mobile => 'mobile',
      _NumberFilter.fixed => 'fixed',
      _NumberFilter.free => 'free',
    };
    for (final offer in offers) {
      if (offer.type == type) return offer;
    }
    return null;
  }

  void _selectFilter(_NumberFilter filter) {
    setState(() {
      _filter = filter;
      _selectedNumber = _firstOfferFor(filter, _offers)?.phoneNumber;
    });
  }

  void _selectCountry(CountryItem? country) {
    if (country == null || country.id == _country.id) return;
    setState(() {
      _country = country;
      _selectedNumber = null;
    });
    _loadNumbers();
  }

  Future<void> _purchase() async {
    final offer = _selectedOffer;
    if (offer == null || _isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      await _dataSource.purchaseNumber(
        phoneNumber: offer.phoneNumber,
        countryCode: _country.code,
      );
      if (!mounted) return;
      Get.snackbar(
        'number.purchase_success'.tr,
        offer.phoneNumber,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'number.purchase_error'.tr,
        'number.retry'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showInfo() {
    final colors = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('number.info_title'.tr),
        content: Text('number.info_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = _selectedOffer;

    return AppScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.space(20),
                r.space(8),
                r.space(20),
                r.space(6),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: r.iconSize(28),
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(width: r.space(8)),
                  Expanded(
                    child: Text(
                      'number.purchase_title'.tr,
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(21),
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Material(
                    color: colors.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _showInfo,
                      child: SizedBox(
                        width: r.space(42),
                        height: r.space(42),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: r.iconSize(21),
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  r.space(20),
                  r.space(8),
                  r.space(20),
                  r.space(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(context, 'number.country'.tr),
                    SizedBox(height: r.space(8)),
                    _countrySelector(context),
                    SizedBox(height: r.space(14)),
                    _sectionLabel(context, 'number.type'.tr),
                    SizedBox(height: r.space(8)),
                    Row(
                      children: [
                        _typeChip(context, _NumberFilter.mobile, 'number.type_mobile'.tr),
                        SizedBox(width: r.space(6)),
                        _typeChip(context, _NumberFilter.fixed, 'number.type_fixed'.tr),
                        SizedBox(width: r.space(6)),
                        _typeChip(context, _NumberFilter.free, 'number.type_free'.tr),
                      ],
                    ),
                    SizedBox(height: r.space(14)),
                    _sectionLabel(context, 'number.available'.tr),
                    SizedBox(height: r.space(8)),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: r.space(36)),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (_hasError)
                      _message(context, 'number.load_error'.tr, retry: true)
                    else if (_filteredOffers.isEmpty)
                      _message(context, 'number.empty'.tr)
                    else
                      for (final offer in _filteredOffers) ...[
                        _offerTile(context, offer),
                        SizedBox(height: r.space(8)),
                      ],
                    SizedBox(height: r.space(8)),
                    _summaryCard(context, selected),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.space(20),
                r.space(6),
                r.space(20),
                r.space(14),
              ),
              child: SizedBox(
                width: double.infinity,
                height: r.heightOf(52),
                child: FilledButton(
                  onPressed: selected == null || _isPurchasing || _isLoading
                      ? null
                      : _purchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.radius(28)),
                    ),
                  ),
                  child: _isPurchasing
                      ? SizedBox(
                          width: r.iconSize(22),
                          height: r.iconSize(22),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'number.buy'.tr,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(15),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text,
    style: GoogleFonts.zillaSlab(
      fontSize: context.responsive.fontSize(13),
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );

  Widget _countrySelector(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final countries = widget.countries.isEmpty
        ? [_country]
        : widget.countries;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(12)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(28)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryItem>(
          value: countries.any((item) => item.id == _country.id)
              ? countries.firstWhere((item) => item.id == _country.id)
              : null,
          isExpanded: true,
          borderRadius: BorderRadius.circular(r.radius(18)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.onSurfaceVariant),
          items: [
            for (final country in countries)
              DropdownMenuItem(
                value: country,
                child: Row(
                  children: [
                    CountryFlagBadge(code: country.code, size: r.space(34)),
                    SizedBox(width: r.space(12)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(country.name, style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(14), fontWeight: FontWeight.w600,
                          )),
                          Text(country.dialCode, style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(11), color: colors.onSurfaceVariant,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          selectedItemBuilder: (context) => countries
              .map((country) => Row(
                    children: [
                      CountryFlagBadge(code: country.code, size: r.space(34)),
                      SizedBox(width: r.space(12)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(country.name, style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(14), fontWeight: FontWeight.w600,
                          )),
                          Text(country.dialCode, style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(11), color: colors.onSurfaceVariant,
                          )),
                        ],
                      ),
                    ],
                  ))
              .toList(),
          onChanged: _selectCountry,
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, _NumberFilter value, String label) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final selected = _filter == value;

    return Expanded(
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(r.radius(14)),
        child: InkWell(
          onTap: () => _selectFilter(value),
          borderRadius: BorderRadius.circular(r.radius(14)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: r.space(10)),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(12),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.onPrimaryContainer : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _offerTile(BuildContext context, NumberOffer offer) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final selected = _selectedNumber == offer.phoneNumber;
    final accent = const Color(0xFFBFE0C4);

    return Material(
      color: selected ? accent.withValues(alpha: 0.68) : colors.surface,
      borderRadius: BorderRadius.circular(r.radius(20)),
      child: InkWell(
        onTap: () => setState(() => _selectedNumber = offer.phoneNumber),
        borderRadius: BorderRadius.circular(r.radius(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.space(14),
            vertical: r.space(13),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.onSurface : colors.onSurfaceVariant,
                size: r.iconSize(20),
              ),
              SizedBox(width: r.space(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.phoneNumber,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(13),
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: r.space(2)),
                    Text(
                      offer.description.tr,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(11),
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(9),
                  vertical: r.space(5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFE0C4),
                  borderRadius: BorderRadius.circular(r.radius(14)),
                ),
                child: Text(
                  _price(offer.price, offer.currency),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(10),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF173B22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, NumberOffer? offer) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final currency = offer?.currency ?? 'USD';
    final amount = offer?.price ?? 0;

    Widget line(String title, String value, {bool total = false}) => Padding(
      padding: EdgeInsets.symmetric(vertical: r.space(total ? 10 : 7)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(total ? 13 : 12),
                fontWeight: total ? FontWeight.w700 : FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: r.fontSize(total ? 13 : 12),
              fontWeight: total ? FontWeight.w700 : FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space(14)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(20)),
      ),
      child: Column(
        children: [
          line('number.monthly_subscription'.tr, _price(amount, currency)),
          line('number.activation_fee'.tr, _price(0, currency)),
          Divider(height: 1, color: colors.outlineVariant),
          line('number.total_today'.tr, _price(amount, currency), total: true),
        ],
      ),
    );
  }

  Widget _message(BuildContext context, String message, {bool retry = false}) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.space(20)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, color: colors.onSurfaceVariant),
            SizedBox(height: r.space(8)),
            Text(message, textAlign: TextAlign.center),
            if (retry)
              TextButton(
                onPressed: _loadNumbers,
                child: Text('common.retry'.tr),
              ),
          ],
        ),
      ),
    );
  }

  String _price(num amount, String currency) {
    final symbol = switch (currency.toUpperCase()) {
      'USD' => r'$ ',
      'EUR' => '€ ',
      'MGA' || 'AR' => 'Ar ',
      final code => '$code ',
    };
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
