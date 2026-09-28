import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/connectivity_service.dart';

/// Ligne « service actif / inactif » (eSIM, renvoi d'appel, SMS).
class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service});

  final ConnectivityService service;

  IconData get _icon => switch (service.type) {
        ConnectivityServiceType.esim => Icons.sim_card_outlined,
        ConnectivityServiceType.callForwarding => Icons.call_outlined,
        ConnectivityServiceType.smsNotification => Icons.drafts_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final status = service.isActive ? 'Actif' : 'Inactif';

    return AppCard(
      child: Row(
        children: [
          IconCircle(_icon),
          SizedBox(width: r.space(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.body(
                    r.fontSize(16),
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(status, style: AppTextStyles.body(r.fontSize(14))),
              ],
            ),
          ),
          service.isActive
              ? StatusBadge.success(status)
              : StatusBadge.neutral(status),
        ],
      ),
    );
  }
}
