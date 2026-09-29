import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/inbox_header.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_group_section.dart';

/// Écran « Notifications » (Figma : Accueil/Notifications).
class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Obx(
              () => InboxHeader(
                title: 'Notifications',
                subtitle: NotificationsController.maskedNumber,
                unreadCount: controller.unreadCount.value,
                onBack: Get.back,
                trailing: RoundIconButton(
                  icon: Icons.filter_list_rounded,
                  onPressed: controller.onFilterPressed,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(() {
                final groups = controller.groups;
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (_, index) =>
                      NotificationGroupSection(group: groups[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
