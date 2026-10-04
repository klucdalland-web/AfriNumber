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
  });

  final String id;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int annualPrice;
  final String currency;
  final List<PlanFeature> features;
  final bool isRecommended;

  bool get isFree => monthlyPrice == 0 && annualPrice == 0;
}
