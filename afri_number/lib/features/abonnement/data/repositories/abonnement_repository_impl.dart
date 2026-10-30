import '../../../../core/errors/api_exception.dart';
import '../datasources/abonnement_remote_datasource.dart';
import '../models/abonnement_checkout_result.dart';
import '../models/abonnement_history_entry.dart';
import '../models/abonnement_plan.dart';
import '../models/billing_period.dart';
import '../models/plan_feature.dart';
import '../../domain/repositories/abonnement_repository.dart';

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
    final rawPlan = json['plan'];
    final plan = rawPlan is Map ? rawPlan : null;
    final id = json['plan_id'] ?? plan?['id'];
    return id == null ? '' : id.toString();
  }

  @override
  Future<List<AbonnementHistoryEntry>> fetchHistory() async {
    final rows = await _remote.fetchHistory();
    return rows
        .whereType<Map>()
        .map((row) => AbonnementHistoryEntry.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  @override
  Future<AbonnementCheckoutResult> subscribe({
    required String planId,
    required BillingPeriod period,
    String? countryCode,
    String? operator,
    String? phone,
  }) async {
    try {
      final json = await _remote.subscribe(
        planId: planId,
        period: period.name,
        countryCode: countryCode,
        operator: operator,
        phone: phone,
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
    final rawFeatures = json['services'] ?? json['features'];
    final features = rawFeatures is List
        ? rawFeatures
            .whereType<Map>()
            .map(
              (feature) => PlanFeature(
                label: _serviceLabel(feature),
                included: feature['included'] != false,
              ),
            )
            .toList()
        : const <PlanFeature>[];

    final price = _asNum(json['price']);

    return AbonnementPlan(
      id: (json['id'] ?? '').toString(),
      name: (json['label'] ?? json['name'] ?? '').toString(),
      tagline: (json['description'] ?? json['tagline'] ?? '').toString(),
      monthlyPrice: _asInt(json['monthly_price'] ?? price),
      annualPrice: _asInt(json['annual_price'] ?? price),
      currency: (json['currency'] ?? 'XOF').toString(),
      features: features,
      isRecommended: json['is_recommended'] == true,
      code: (json['code'] ?? '').toString(),
      price: json.containsKey('price') ? price : null,
      durationDays: _asInt(json['duration_days']),
      maxNumbers: _asInt(json['max_numbers']),
      currently: json['currently'] == true,
    );
  }

  String _serviceLabel(Map<dynamic, dynamic> service) {
    final label = (service['label'] ?? service['code'] ?? '').toString();
    final quota = service['quota'];
    return quota == null ? label : '$label ($quota)';
  }

  num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
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
