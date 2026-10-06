import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/inbox_header.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/user_notification.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_item.dart';
import '../widgets/notification_group_section.dart';

/// Écran des notifications du compte connecté.
class NotificationsTab extends GetView<NotificationsController> {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => InboxHeader(
                title: 'notifications.title'.tr,
                subtitle: 'notifications.subtitle'.tr,
                unreadCount: controller.unreadCount.value,
                onBack: Get.back,
                trailing: RoundIconButton(
                  icon: controller.unreadOnly.value
                      ? Icons.mark_email_unread_outlined
                      : Icons.filter_list_rounded,
                  onPressed: controller.isLoading.value || controller.isLoadingMore.value
                      ? null
                      : controller.onFilterPressed,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  Obx(
                    () => TextButton.icon(
                      onPressed: controller.isLoading.value ||
                              controller.unreadCount.value == 0 ||
                              controller.isMarkingAllRead.value
                          ? null
                          : controller.markAllAsRead,
                      icon: controller.isMarkingAllRead.value
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : const Icon(Icons.done_all_rounded, size: 18),
                      label: Text('notifications.mark_all_read'.tr),
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      controller.unreadOnly.value
                          ? 'notifications.filter_unread'.tr
                          : 'notifications.filter_all'.tr,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.isNotEmpty &&
                    controller.notifications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.errorMessage.value, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => controller.loadNotifications(refresh: true),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('common.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final groups = controller.groups;
                return RefreshIndicator(
                  onRefresh: () => controller.loadNotifications(refresh: true),
                  child: ListView.separated(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.paddingOf(context).bottom + 16,
                    ),
                    itemCount: groups.isEmpty
                        ? 1
                        : groups.length + (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      if (groups.isEmpty) {
                        return SizedBox(
                          height: 240,
                          child: Center(
                            child: Text(
                              controller.unreadOnly.value
                                  ? 'notifications.empty_unread'.tr
                                  : 'notifications.empty'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ),
                        );
                      }
                      if (index >= groups.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return NotificationGroupSection(
                        group: groups[index],
                        onNotificationTap: (item) => _openDetails(context, item),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, NotificationItem item) async {
    final detail = await controller.loadDetails(item);
    if (!context.mounted || detail == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _NotificationDetailsSheet(
        notification: detail,
        onDelete: () async {
          final delete = await showDialog<bool>(
            context: sheetContext,
            builder: (dialogContext) => AlertDialog(
              title: Text('notifications.delete_title'.tr),
              content: Text('notifications.delete_body'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text('common.cancel'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text('notifications.delete'.tr),
                ),
              ],
            ),
          );
          if (delete != true) return;
          final deleted = await controller.deleteNotification(detail.id);
          if (deleted && sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

class _NotificationDetailsSheet extends StatelessWidget {
  const _NotificationDetailsSheet({
    required this.notification,
    required this.onDelete,
  });

  final UserNotification notification;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = notification.createdAt;
    final dateLabel = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'notifications.details'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'notifications.delete'.tr,
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(notification.title, style: Theme.of(context).textTheme.titleMedium),
            if ((notification.typeLabel ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                notification.typeLabel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
            if (dateLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Text(notification.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
