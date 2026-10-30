import 'plan_feature.dart';

class AbonnementPlan {
  const AbonnementPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.currency,
    required this.features,
    this.isRecommended = false,
    this.code = '',
    this.price,
    this.durationDays = 0,
    this.maxNumbers = 0,
    this.currently = false,
  });

  final String id;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int annualPrice;
  final String currency;
  final List<PlanFeature> features;
  final bool isRecommended;
  final String code;
  final num? price;
  final int durationDays;
  final int maxNumbers;
  final bool currently;

  bool get isFree => price != null
      ? price == 0
      : monthlyPrice == 0 && annualPrice == 0;
}
