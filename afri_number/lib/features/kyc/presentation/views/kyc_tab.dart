import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/kyc_controller.dart';
import '../widgets/widgets.dart';

/// Page du parcours KYC (pièce, recto/verso, visage, vérification, validation).
class KycPage extends StatelessWidget {
  /// Crée la page KYC.
  const KycPage({super.key});

  @override
  Widget build(BuildContext context) {
    final KycController c = Get.find<KycController>();
    final r = context.responsive;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) c.goBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              KycHeader(
                onBack: c.goBack,
                onInfo: () => _showInfo(context),
              ),
              Obx(
                    () => c.showProgress
                    ? KycStepIndicator(current: c.progressIndex)
                    : SizedBox(height: r.space(3)),
              ),
              SizedBox(height: r.space(16)),
              Expanded(child: Obx(() => _buildStep(c))),
              Padding(
                padding: EdgeInsets.all(r.space(16)),
                child: Obx(() => _buildButton(c)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(KycController c) {
    switch (c.step.value) {
      case KycStep.choose:
        return KycDocumentList(controller: c);
      case KycStep.front:
        return KycCaptureStep(
          title: 'kyc.front.title'.tr,
          subtitle: 'kyc.front.subtitle'.tr,
          icon: Icons.photo_camera_outlined,
          errorMessage: c.errorMessage.value,
        );
      case KycStep.back:
        return KycCaptureStep(
          title: 'kyc.back.title'.tr,
          subtitle: 'kyc.back.subtitle'.tr,
          icon: Icons.photo_camera_outlined,
          errorMessage: c.errorMessage.value,
        );
      case KycStep.face:
        return KycCaptureStep(
          title: 'kyc.face.title'.tr,
          subtitle: 'kyc.face.subtitle'.tr,
          icon: Icons.person_outline,
          errorMessage: c.errorMessage.value,
        );
      case KycStep.verifying:
        return KycStatusStep(
          isLoading: true,
          title: 'kyc.verifying.title'.tr,
          body: 'kyc.verifying.body'.tr,
        );
      case KycStep.verified:
        return KycStatusStep(
          isLoading: false,
          title: 'kyc.verified.title'.tr,
          body: 'kyc.verified.body'.tr,
        );
    }
  }

  Widget _buildButton(KycController c) {
    switch (c.step.value) {
      case KycStep.choose:
        return AppButton(
          label: 'kyc.continue'.tr,
          onPressed:
          c.selectedType.value == null ? null : c.onPrimaryPressed,
        );
      case KycStep.front:
      case KycStep.back:
        return AppButton(
          label: 'kyc.take_photo'.tr,
          isLoading: c.isBusy.value,
          onPressed: c.onPrimaryPressed,
        );
      case KycStep.face:
        return AppButton(
          label: 'kyc.start_scan'.tr,
          isLoading: c.isBusy.value,
          onPressed: c.onPrimaryPressed,
        );
      case KycStep.verifying:
      // Grisé tant que la vérification n'est pas terminée (comme la maquette).
        return AppButton(label: 'kyc.verifying.home'.tr, onPressed: null);
      case KycStep.verified:
        return AppButton(
          label: 'kyc.verified.buy'.tr,
          onPressed: c.onBuyNumber,
        );
    }
  }

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('kyc.info.title'.tr),
        content: Text('kyc.info.body'.tr),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('kyc.info.close'.tr),
          ),
        ],
      ),
    );
  }
}