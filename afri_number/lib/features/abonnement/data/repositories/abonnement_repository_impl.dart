import '../../../../core/errors/api_exception.dart';
import '../datasources/abonnement_remote_datasource.dart';
import '../models/abonnement_checkout_result.dart';
import '../models/abonnement_plan.dart';
import '../models/billing_period.dart';
import '../models/plan_feature.dart';
import 'abonnement_repository.dart';

class AbonnementRepositoryImpl implements AbonnementRepository {
  AbonnementRepositoryImpl(this._remote);

  final AbonnementRemoteDataSource _remote;

  @override
  Future<List<AbonnementPlan>> fetchPlans() async {
    final rawPlans = await _remote.fetchPlans();
    return rawPlans
        .whereType<Map>()
        .map((json) => _planFromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<String> fetchCurrentPlanId() async {
    final json = await _remote.fetchCurrent();
    final id = json['plan_id'] ?? json['id'];
    return id == null ? '' : id.toString();
  }

  @override
  Future<AbonnementCheckoutResult> subscribe({
    required String planId,
    required BillingPeriod period,
  }) async {
    try {
      final json = await _remote.subscribe(
        planId: planId,
        period: period.name,
      );
      final statusText = json['status'] as String?;
      return AbonnementCheckoutResult(
        status: _statusFromText(statusText),
        checkoutUrl: json['checkout_url'] as String?,
        message: json['message'] as String?,
      );
    } on ApiException catch (e) {
      return AbonnementCheckoutResult(
        status: AbonnementCheckoutStatus.failed,
        message: e.message,
      );
    }
  }

  AbonnementPlan _planFromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures
            .whereType<Map>()
            .map(
              (feature) => PlanFeature(
                label: (feature['label'] ?? '').toString(),
                included: feature['included'] == true,
              ),
            )
            .toList()
        : const <PlanFeature>[];

    return AbonnementPlan(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      tagline: (json['tagline'] ?? '').toString(),
      monthlyPrice: _asInt(json['monthly_price']),
      annualPrice: _asInt(json['annual_price']),
      currency: (json['currency'] ?? 'Ar').toString(),
      features: features,
      isRecommended: json['is_recommended'] == true,
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  AbonnementCheckoutStatus _statusFromText(String? status) {
    switch (status) {
      case 'requires_action':
        return AbonnementCheckoutStatus.requiresAction;
      case 'failed':
        return AbonnementCheckoutStatus.failed;
      default:
        return AbonnementCheckoutStatus.success;
    }
  }
}
