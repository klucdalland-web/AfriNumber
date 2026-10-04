import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive.dart';
import '../controllers/kyc_controller.dart';
import 'kyc_document_option.dart';

/// Étape 1 : liste des pièces (loading / erreur / vide / contenu).
class KycDocumentList extends StatelessWidget {
  /// Crée la liste des pièces.
  const KycDocumentList({super.key, required this.controller});

  /// Contrôleur KYC.
  final KycController controller;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final Widget body;
      if (controller.isLoading.value && controller.documentTypes.isEmpty) {
        body = const Center(child: CircularProgressIndicator());
      } else if (controller.errorMessage.value != null &&
          controller.documentTypes.isEmpty) {
        body = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(r.space(16)),
          children: <Widget>[
            SizedBox(height: r.space(48)),
            Text(
              controller.errorMessage.value!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fontSize(13),
                color: scheme.error,
              ),
            ),
            SizedBox(height: r.space(12)),
            Center(
              child: TextButton(
                onPressed: controller.load,
                child: Text('common.retry'.tr),
              ),
            ),
          ],
        );
      } else if (controller.documentTypes.isEmpty) {
        body = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(r.space(16)),
          children: <Widget>[
            SizedBox(height: r.space(48)),
            Text(
              'kyc.empty'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fontSize(13),
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      } else {
        body = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: r.space(16)),
          children: <Widget>[
            Text(
              'kyc.choose.title'.tr,
              style: TextStyle(
                fontSize: r.fontSize(15),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: r.space(2)),
            Text(
              'kyc.choose.subtitle'.tr,
              style: TextStyle(
                fontSize: r.fontSize(12),
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: r.space(16)),
            for (final type in controller.documentTypes) ...<Widget>[
              KycDocumentOption(
                type: type,
                selected: controller.selectedType.value?.id == type.id,
                onTap: () => controller.selectType(type),
              ),
              SizedBox(height: r.space(12)),
            ],
          ],
        );
      }
      return RefreshIndicator(onRefresh: controller.load, child: body);
    });
  }
}