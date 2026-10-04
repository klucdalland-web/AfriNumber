import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/billing_period.dart';
import '../../data/models/abonnement_plan.dart';
import 'plan_feature_row.dart';

class AbonnementPlanCard extends StatelessWidget {
  const AbonnementPlanCard({
    super.key,
    required this.plan,
    required this.period,
    required this.isCurrent,
    required this.isProcessing,
    required this.onSubscribe,
  });

  final AbonnementPlan plan;
  final BillingPeriod period;
  final bool isCurrent;
  final bool isProcessing;
  final VoidCallback onSubscribe;

  static const _buttonColor = Color(0xFF686868);

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final price = plan.price ??
        (period == BillingPeriod.monthly ? plan.monthlyPrice : plan.annualPrice);
    final periodLabel = plan.durationDays > 0
        ? 'abonnement.duration_days'
              .trParams({'days': plan.durationDays.toString()})
        : ' / ${period.unitKey.tr}';

    return Padding(
      padding: EdgeInsets.only(
        top: plan.isRecommended ? r.space(18) : 0,
        bottom: r.space(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(r.space(20)),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(r.radius(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nom du plan et prix ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: AppTextStyles.sectionTitle(r.fontSize(22))
                          .copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Affichage "Gratuit" ou prix avec période traduite
                    if (plan.isFree)
                      Text(
                        'abonnement.free'.tr,
                        style: AppTextStyles.sectionTitle(r.fontSize(22)),
                      )
                    else
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: Formatters.amount(price,
                                currency: plan.currency),
                            style: AppTextStyles.sectionTitle(r.fontSize(22)),
                          ),
                          TextSpan(
                            // Unité de période traduite (mois / an)
                            text: periodLabel,
                            style: AppTextStyles.body(
                              r.fontSize(16),
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),

                SizedBox(height: r.space(4)),

                // ── Tagline du plan ──
                Text(
                  plan.tagline,
                  style: AppTextStyles.body(
                    r.fontSize(14),
                    weight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),

                SizedBox(height: r.space(18)),

                // ── Liste des fonctionnalités ──
                for (final feature in plan.features)
                  PlanFeatureRow(feature: feature),

                SizedBox(height: r.space(8)),

                // ── Bouton d'action traduit ──
                AppButton.primary(
                  label: isCurrent
                      // Plan déjà souscrit
                      ? 'abonnement.current_plan'.tr
                      // Invite à souscrire avec interpolation du nom
                      : 'abonnement.subscribe'
                          .trParams({'plan': plan.name}),
                  isLoading: isProcessing,
                  onPressed: isCurrent ? null : onSubscribe,
                  backgroundColor: _buttonColor,
                  foregroundColor: Colors.white,
                  radius: r.radius(28),
                  height: r.heightOf(56),
                ),
              ],
            ),
          ),

          // ── Badge "Recommandé" traduit ──
          if (plan.isRecommended)
            Positioned(
              top: -r.space(8),
              right: r.space(18),
              child: StatusBadge.success('abonnement.recommended'.tr),
            ),
        ],
      ),
    );
  }
}
