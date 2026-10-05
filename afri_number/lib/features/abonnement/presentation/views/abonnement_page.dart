import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/abonnement_controller.dart';
import '../widgets/mobile_money_payment_sheet.dart';
import '../widgets/abonnement_plan_card.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_plan.dart';
import '../widgets/abonnement_plan_card_skeleton.dart';
import '../widgets/skeleton.dart';

class AbonnementPage extends GetView<AbonnementController> {
  const AbonnementPage({super.key});

  Future<void> _handleSubscribe(
    BuildContext context,
    AbonnementPlan plan,
  ) async {
    final AbonnementCheckoutResult? result;
    if (plan.isFree) {
      result = await controller.subscribe(plan.id);
    } else {
      final amount = plan.price ?? plan.annualPrice;
      final amountLabel = Formatters.amount(amount, currency: plan.currency);
      result = await showMobileMoneyPaymentSheet(
        context,
        countryCode: controller.countryCode,
        planName: plan.name,
        amountLabel: amountLabel,
        onPay: (request) => controller.subscribe(
          plan.id,
          countryCode: request.countryCode,
          operator: request.operator.id,
          phone: request.phone,
        ),
      );
    }
    if (result == null) return;
    final checkoutResult = result;
    if (!context.mounted) return;
    final colors = Theme.of(context).colorScheme;

    final isSuccess =
        checkoutResult.status == AbonnementCheckoutStatus.success;

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
          checkoutResult.message ??
              (isSuccess
                  // Message avec interpolation du nom du plan
                  ? 'abonnement.activated_msg'.trParams({'plan': plan.name})
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'abonnement.title'.tr,
                          style: AppTextStyles.screenTitle(r.fontSize(28)),
                        ),
                        if (currentPlanName?.trim().isNotEmpty == true)
                          Text(
                            currentPlanName!,
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

              // ── États : chargement / erreur / liste des plans ──
             if (controller.isLoading.value && plans.isEmpty)
  const SkeletonShimmer(
    child: Column(
      children: [
        AbonnementPlanCardSkeleton(),
        AbonnementPlanCardSkeleton(),
        AbonnementPlanCardSkeleton(),
      ],
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
                    onSubscribe: () => _handleSubscribe(context, plan),
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
