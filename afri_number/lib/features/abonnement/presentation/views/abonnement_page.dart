import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/abonnement_controller.dart';
import '../widgets/billing_period_toggle.dart';
import '../widgets/abonnement_plan_card.dart';
import '../../data/models/abonnement_checkout_result.dart';
import '../../data/models/abonnement_plan.dart';

class AbonnementPage extends GetView<AbonnementController> {
  const AbonnementPage({super.key});

  Future<void> _handleSubscribe(BuildContext context, String planId, String planName) async {
    final result = await controller.subscribe(planId);
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(result.status == AbonnementCheckoutStatus.success ? 'Abonnement activé' : 'Action requise'),
        content: Text(
          result.message ??
              (result.status == AbonnementCheckoutStatus.success
                  ? 'Vous êtes maintenant sur l\'offre $planName.'
                  : 'Veuillez réessayer.'),
        ),
        actions: [
          AppButton.text(
            label: 'OK',
            onPressed: () => Navigator.of(dialogContext).pop(),
            foregroundColor: AppColors.ink,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final plans = controller.plans;
          final currentPlanId = controller.currentPlanId.value;
          final currentPlanName = _planNameOf(plans, currentPlanId);

          return ListView(
            padding: EdgeInsets.fromLTRB(r.space(18), r.space(16), r.space(18), r.space(40)),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.chevron_left, size: r.iconSize(28), color: AppColors.ink),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: r.space(4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Abonnement', style: AppTextStyles.screenTitle(r.fontSize(28))),
                        if (currentPlanName != null)
                          Text(
                            currentPlanName,
                            style: AppTextStyles.body(r.fontSize(16), color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  _InfoButton(),
                ],
              ),
              SizedBox(height: r.space(20)),
              Text(
                'Choisissez l\'offre qui vous convient.',
                style: AppTextStyles.sectionTitle(r.fontSize(19)),
              ),
              SizedBox(height: r.space(4)),
              Text(
                'Changez de formule à tout moment.',
                style: AppTextStyles.body(r.fontSize(15), color: AppColors.textMuted),
              ),
              SizedBox(height: r.space(20)),
              BillingPeriodToggle(
                selected: controller.period.value,
                onChanged: controller.selectPeriod,
              ),
              SizedBox(height: r.space(8)),
              if (controller.isLoading.value && plans.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: r.space(60)),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.ink)),
                )
              else if (controller.errorMessage.isNotEmpty && plans.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(controller.errorMessage.value),
                      AppButton.text(
                        label: 'Réessayer',
                        onPressed: controller.load,
                        foregroundColor: AppColors.ink,
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
                    isCurrent: plan.id == currentPlanId,
                    isProcessing: controller.processingPlanId.value == plan.id,
                    onSubscribe: () => _handleSubscribe(context, plan.id, plan.name),
                  ),
            ],
          );
        }),
      ),
    );
  }
}

String? _planNameOf(List<AbonnementPlan> plans, String id) {
  for (final plan in plans) {
    if (plan.id == id) return plan.name;
  }
  return null;
}

class _InfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: SizedBox(
          width: r.iconSize(44),
          height: r.iconSize(44),
          child: Icon(Icons.info_outline, size: r.iconSize(22), color: AppColors.ink),
        ),
      ),
    );
  }
}
