import '../models/billing_period.dart';
import '../models/plan_feature.dart';
import '../models/abonnement_checkout_result.dart';
import '../models/abonnement_plan.dart';
import '../models/abonnement_history_entry.dart';
import '../../domain/repositories/abonnement_repository.dart';

class MockAbonnementRepository implements AbonnementRepository {
  String _currentPlanId = 'basique';

  @override
  Future<List<AbonnementPlan>> fetchPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      AbonnementPlan(
        id: 'premium',
        name: 'Premium',
        tagline: 'Pour les freelancers internationaux et les commercants',
        monthlyPrice: 15000,
        annualPrice: 150000,
        currency: 'Ar',
        isRecommended: true,
        features: [
          PlanFeature(label: '5 numéros internationaux actifs', included: true),
          PlanFeature(label: 'SMS illimités (usage raisonnable)', included: true),
          PlanFeature(label: 'Mode Zéro Data inclus (200 min/mois)', included: true),
          PlanFeature(label: 'Traduction SMS illimitée', included: true),
          PlanFeature(label: 'Pare-feu anti-fraude avancé', included: true),
          PlanFeature(label: 'KYC et retraits prioritaires', included: true),
        ],
      ),
      AbonnementPlan(
        id: 'basique',
        name: 'Basique',
        tagline: 'Pour les étudiants et les petits commerces',
        monthlyPrice: 0,
        annualPrice: 0,
        currency: 'Ar',
        features: [
          PlanFeature(label: '1 numéros internationaux actifs', included: true),
          PlanFeature(label: '50 SMS reçus / mois', included: true),
          PlanFeature(label: 'Mode Zéro Data non inclus', included: false),
          PlanFeature(label: '20 traductions SMS / mois', included: true),
          PlanFeature(label: 'Pare-feu anti-fraude standard', included: true),
          PlanFeature(label: 'KYC et retraits standards', included: false),
        ],
      ),
    ];
  }

  @override
  Future<String> fetchCurrentPlanId() async => _currentPlanId;

  @override
  Future<List<AbonnementHistoryEntry>> fetchHistory() async => const [];

  @override
  Future<AbonnementCheckoutResult> subscribe({
    required String planId,
    required BillingPeriod period,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _currentPlanId = planId;
    return const AbonnementCheckoutResult(
      status: AbonnementCheckoutStatus.success,
    );
  }
}
