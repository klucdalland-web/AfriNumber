import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_history_entry.dart';
import '../../data/models/abonnement_plan.dart';
import '../../data/models/billing_period.dart';

abstract class AbonnementRepository {
  Future<List<AbonnementPlan>> fetchPlans();

  Future<String> fetchCurrentPlanId();

  Future<List<AbonnementHistoryEntry>> fetchHistory();

  Future<AbonnementCheckoutResult> subscribe({
    required String planId,
    required BillingPeriod period,
  });
}
