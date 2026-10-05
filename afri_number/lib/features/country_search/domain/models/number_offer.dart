class NumberOffer {
  const NumberOffer({
    required this.phoneNumber,
    required this.price,
    required this.currency,
    required this.type,
    required this.description,
  });

  final String phoneNumber;
  final num price;
  final String currency;
  final String type;
  final String description;

  factory NumberOffer.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'] ?? json['monthly_price'] ?? 0;
    final priceMap = rawPrice is Map ? rawPrice : null;
    final priceValue = priceMap?['amount'] ?? rawPrice;
    final price = priceValue is num
        ? priceValue
        : num.tryParse(priceValue?.toString() ?? '') ?? 0;
    final features = json['features'] ?? json['capabilities'];
    final supportsSms = json['sms'] == true ||
        json['sms_enabled'] == true ||
        (features is List && features.any((value) => value.toString().toLowerCase().contains('sms')));
    final supportsVoice = json['voice'] == true ||
        json['voice_enabled'] == true ||
        json['calls'] == true ||
        (features is List && features.any((value) =>
            value.toString().toLowerCase().contains('voice') ||
            value.toString().toLowerCase().contains('call')));
    final rawType = (json['type'] ?? json['number_type'] ?? json['kind'] ?? 'mobile')
        .toString()
        .toLowerCase();

    return NumberOffer(
      phoneNumber: (json['phone_number'] ?? json['number'] ?? json['phone'] ?? '')
          .toString(),
      price: price,
      currency: (json['currency'] ?? priceMap?['currency'] ?? 'USD').toString(),
      type: rawType.contains('fix') || rawType.contains('landline')
          ? 'fixed'
          : rawType.contains('free') || price == 0
              ? 'free'
              : 'mobile',
      description: supportsSms && supportsVoice
          ? 'number.feature_sms_calls'
          : supportsSms
              ? 'number.feature_sms'
              : supportsVoice
                  ? 'number.feature_calls'
                  : 'number.feature_unknown',
    );
  }
}
