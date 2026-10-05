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

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final highlighted = plan.isRecommended || isCurrent;

    final price = plan.price ??
        (period == BillingPeriod.monthly
            ? plan.monthlyPrice
            : plan.annualPrice);
    final periodLabel = plan.durationDays > 0
        ? 'abonnement.duration_days'
            .trParams({'days': plan.durationDays.toString()})
        : '/ ${period.unitKey.tr}';

    // ── Fond de carte : on part d'un container légèrement élevé
    final baseSurface = isDark
        ? Color.alphaBlend(
            colors.surfaceTint.withOpacity(0.04),
            colors.surfaceContainerLow,
          )
        : colors.surface;

    // ── Fond surligné : teinte primaire subtile
    final highlightedSurface = Color.alphaBlend(
      colors.primary.withOpacity(isDark ? 0.14 : 0.07),
      baseSurface,
    );

    // ── Bordure : plus visible en sombre
    final borderColor = highlighted
        ? colors.primary.withOpacity(isDark ? 0.85 : 0.7)
        : colors.outlineVariant.withOpacity(isDark ? 0.5 : 0.6);

    // ── Ombre : adaptée au thème
    final shadowColor = highlighted
        ? colors.primary.withOpacity(isDark ? 0.22 : 0.14)
        : Colors.black.withOpacity(isDark ? 0.35 : 0.05);

    // ── Couleurs du bouton selon l'état et le thème ──
    final Color buttonBackground;
    final Color buttonForeground;

    if (isCurrent) {
      // Plan actuel : bouton désactivé, discret
      buttonBackground = isDark
          ? colors.surfaceContainerHighest
          : colors.surfaceContainerHigh;
      buttonForeground = colors.onSurfaceVariant;
    } else if (plan.isRecommended) {
      // Plan recommandé : couleur primaire
      buttonBackground = colors.primary;
      buttonForeground = colors.onPrimary;
    } else {
      // Plan standard : neutre, adapté au thème
      buttonBackground = isDark
          ? const Color(0xFF3A3A3A)
          : const Color(0xFF6B6B6B);
      buttonForeground = Colors.white;
    }

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
                  highlighted ? highlightedSurface : baseSurface,
                  highlighted
                      ? Color.alphaBlend(
                          colors.primary.withOpacity(isDark ? 0.06 : 0.03),
                          baseSurface,
                        )
                      : baseSurface,
                ],
              ),
              border: Border.all(
                color: borderColor,
                width: highlighted ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: r.space(highlighted ? 26 : 16),
                  offset: Offset(0, r.space(highlighted ? 10 : 6)),
                  spreadRadius: highlighted ? r.space(0.5) : 0,
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
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
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
                  color:
                      colors.outlineVariant.withOpacity(isDark ? 0.4 : 0.5),
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
                  backgroundColor: buttonBackground,
                  foregroundColor: buttonForeground,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priceColor = isDark
        ? Color.alphaBlend(Colors.white.withOpacity(0.15), colors.primary)
        : colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountLabel,
          style: AppTextStyles.sectionTitle(r.fontSize(24)).copyWith(
            fontWeight: FontWeight.w800,
            color: priceColor,
          ),
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