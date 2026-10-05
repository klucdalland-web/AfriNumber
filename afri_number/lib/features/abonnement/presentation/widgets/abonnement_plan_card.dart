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

  static const _neutralButtonColor = Color(0xFF686868);

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final highlighted = plan.isRecommended || isCurrent;

    final price = plan.price ??
        (period == BillingPeriod.monthly ? plan.monthlyPrice : plan.annualPrice);
    final periodLabel = plan.durationDays > 0
        ? 'abonnement.duration_days'
            .trParams({'days': plan.durationDays.toString()})
        : '/ ${period.unitKey.tr}';

    return Padding(
      padding: EdgeInsets.only(
        top: plan.isRecommended ? r.space(14) : 0,
        bottom: r.space(18),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.all(r.space(20)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(28)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface,
                  highlighted
                      ? Color.alphaBlend(
                          colors.primary.withOpacity(0.08),
                          colors.surface,
                        )
                      : colors.surface,
                ],
              ),
              border: Border.all(
                color: highlighted
                    ? colors.primary.withOpacity(0.7)
                    : colors.outlineVariant.withOpacity(0.4),
                width: highlighted ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (highlighted ? colors.primary : Colors.black)
                      .withOpacity(highlighted ? 0.12 : 0.05),
                  blurRadius: r.space(highlighted ? 24 : 14),
                  offset: Offset(0, r.space(8)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête : nom + tagline / prix ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.sectionTitle(r.fontSize(22))
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (plan.tagline.trim().isNotEmpty) ...[
                            SizedBox(height: r.space(4)),
                            Text(
                              plan.tagline,
                              style: AppTextStyles.body(
                                r.fontSize(14),
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: r.space(12)),
                    _PriceBlock(
                      isFree: plan.isFree,
                      amountLabel: plan.isFree
                          ? 'abonnement.free'.tr
                          : Formatters.amount(price, currency: plan.currency),
                      periodLabel: plan.isFree ? null : periodLabel,
                    ),
                  ],
                ),

                SizedBox(height: r.space(16)),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withOpacity(0.5),
                ),
                SizedBox(height: r.space(16)),

                // ── Fonctionnalités ──
                for (final feature in plan.features)
                  PlanFeatureRow(feature: feature),

                SizedBox(height: r.space(12)),

                // ── Bouton d'action ──
                AppButton.primary(
                  label: isCurrent
                      ? 'abonnement.current_plan'.tr
                      : 'abonnement.subscribe'.trParams({'plan': plan.name}),
                  isLoading: isProcessing,
                  onPressed: isCurrent ? null : onSubscribe,
                  backgroundColor:
                      plan.isRecommended ? colors.primary : _neutralButtonColor,
                  foregroundColor: Colors.white,
                  radius: r.radius(28),
                  height: r.heightOf(56),
                ),
              ],
            ),
          ),

          // ── Badge recommandé ──
          if (plan.isRecommended)
            Positioned(
              top: -r.space(12),
              right: r.space(20),
              child: StatusBadge.success('abonnement.recommended'.tr),
            ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.isFree,
    required this.amountLabel,
    required this.periodLabel,
  });

  final bool isFree;
  final String amountLabel;
  final String? periodLabel;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountLabel,
          style: AppTextStyles.sectionTitle(r.fontSize(24))
              .copyWith(fontWeight: FontWeight.w800, color: colors.primary),
        ),
        if (periodLabel != null)
          Text(
            periodLabel!,
            style: AppTextStyles.body(
              r.fontSize(13),
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}