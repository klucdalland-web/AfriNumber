import '../models/billing_period.dart';
import '../models/abonnement_checkout_result.dart';
import '../models/abonnement_plan.dart';

abstract class AbonnementRepository {
  Future<List<AbonnementPlan>> fetchPlans();

  Future<String> fetchCurrentPlanId();

  Future<AbonnementCheckoutResult> subscribe({
    required String planId,
    required BillingPeriod period,
  });
}
