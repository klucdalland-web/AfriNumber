import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/abonnement_controller.dart';
import '../widgets/billing_period_toggle.dart';
import '../widgets/abonnement_plan_card.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_plan.dart';

class AbonnementPage extends GetView<AbonnementController> {
  const AbonnementPage({super.key});

  Future<void> _handleSubscribe(
    BuildContext context,
    String planId,
    String planName,
  ) async {
    final result = await controller.subscribe(planId);
    if (!context.mounted) return;
    final colors = Theme.of(context).colorScheme;

    final isSuccess = result.status == AbonnementCheckoutStatus.success;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        // Titre traduit selon le statut du paiement
        title: Text(
          isSuccess
              ? 'abonnement.activated'.tr
              : 'abonnement.action_required'.tr,
        ),
        content: Text(
          result.message ??
              (isSuccess
                  // Message avec interpolation du nom du plan
                  ? 'abonnement.activated_msg'.trParams({'plan': planName})
                  : 'abonnement.retry_msg'.tr),
        ),
        actions: [
          AppButton.text(
            label: 'OK',
            onPressed: () => Navigator.of(dialogContext).pop(),
            foregroundColor: colors.onSurface,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;

    return AppScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final plans = controller.plans;
          final currentPlanId = controller.currentPlanId.value;
          final currentPlanName = _planNameOf(plans, currentPlanId);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              r.space(18),
              r.space(16),
              r.space(18),
              r.space(40),
            ),
            children: [
              // ── En-tête avec bouton retour et titre traduit ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.chevron_left,
                      size: r.iconSize(28),
                      color: colors.onSurface,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: r.space(4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de la page traduit
                        Text(
                          'abonnement.title'.tr,
                          style: AppTextStyles.screenTitle(r.fontSize(28)),
                        ),
                        // Nom du forfait actuel, si disponible
                        if (currentPlanName != null)
                          Text(
                            currentPlanName,
                            style: AppTextStyles.body(
                              r.fontSize(16),
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _InfoButton(),
                ],
              ),

              SizedBox(height: r.space(20)),

              // ── Sous-titre invitant au choix d'offre ──
              Text(
                'abonnement.choose'.tr,
                style: AppTextStyles.sectionTitle(r.fontSize(19)),
              ),
              SizedBox(height: r.space(4)),
              Text(
                'abonnement.change_anytime'.tr,
                style: AppTextStyles.body(
                  r.fontSize(15),
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: r.space(20)),

              // ── Sélecteur de période de facturation ──
              if (!plans.any((plan) => plan.durationDays > 0)) ...[
                BillingPeriodToggle(
                  selected: controller.period.value,
                  onChanged: controller.selectPeriod,
                ),
                SizedBox(height: r.space(8)),
              ],

              // ── États : chargement / erreur / liste des plans ──
              if (controller.isLoading.value && plans.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: r.space(60)),
                  child: Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                )
              else if (controller.errorMessage.isNotEmpty && plans.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(controller.errorMessage.value),
                      AppButton.text(
                        label: 'abonnement.retry'.tr,
                        onPressed: controller.load,
                        foregroundColor: colors.onSurface,
                        underline: true,
                      ),
                    ],
                  ),
                )
              else
                for (final plan in plans)
                  AbonnementPlanCard(
                    plan: plan,
                    period: controller.period.value,
                    isCurrent: currentPlanId.isNotEmpty
                        ? plan.id == currentPlanId
                        : plan.currently,
                    isProcessing: controller.processingPlanId.value == plan.id,
                    onSubscribe: () =>
                        _handleSubscribe(context, plan.id, plan.name),
                  ),
              if (controller.history.isNotEmpty) ...[
                SizedBox(height: r.space(12)),
                Text(
                  'abonnement.history_title'.tr,
                  style: AppTextStyles.sectionTitle(r.fontSize(19)),
                ),
                SizedBox(height: r.space(10)),
                for (final entry in controller.history)
                  Container(
                    margin: EdgeInsets.only(bottom: r.space(10)),
                    padding: EdgeInsets.all(r.space(16)),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(r.radius(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.planName.isEmpty
                              ? 'abonnement.title'.tr
                              : entry.planName,
                          style: AppTextStyles.body(
                            r.fontSize(16),
                            weight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        SizedBox(height: r.space(4)),
                        Text(
                          [
                            entry.status,
                            if (entry.startsAt != null)
                              _formatDate(entry.startsAt!),
                            if (entry.endsAt != null)
                              _formatDate(entry.endsAt!),
                          ].where((value) => value.isNotEmpty).join(' · '),
                          style: AppTextStyles.body(
                            r.fontSize(13),
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

/// Retourne le nom du plan correspondant à [id] dans la liste [plans].
String? _planNameOf(List<AbonnementPlan> plans, String id) {
  for (final plan in plans) {
    if (plan.id == id) return plan.name;
  }
  return null;
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Bouton d'information circulaire en haut à droite de l'écran.
class _InfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: SizedBox(
          width: r.iconSize(44),
          height: r.iconSize(44),
          child: Icon(
            Icons.info_outline,
            size: r.iconSize(22),
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
