import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/abonnement_history_entry.dart';
import '../controllers/abonnement_controller.dart';

class AbonnementHistoryPage extends GetView<AbonnementController> {
  const AbonnementHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.space(18),
                r.space(14),
                r.space(18),
                r.space(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: r.iconSize(28),
                      color: colors.onSurface,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: r.space(10)),
                  Expanded(
                    child: Text(
                      'abonnement.history_title'.tr,
                      style: AppTextStyles.screenTitle(r.fontSize(24)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'abonnement.retry'.tr,
                    onPressed: controller.loadHistory,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final history = controller.history;
                if (controller.isHistoryLoading.value && history.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.historyErrorMessage.isNotEmpty &&
                    history.isEmpty) {
                  return _HistoryMessage(
                    message: controller.historyErrorMessage.value,
                    actionLabel: 'abonnement.retry'.tr,
                    onAction: controller.loadHistory,
                  );
                }
                if (history.isEmpty) {
                  return _HistoryMessage(
                    message: 'abonnement.history_empty'.tr,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadHistory,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      r.space(18),
                      r.space(8),
                      r.space(18),
                      r.space(28),
                    ),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => SizedBox(height: r.space(10)),
                    itemBuilder: (context, index) => _HistoryCard(
                      entry: history[index],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final AbonnementHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final status = entry.status.toLowerCase();
    final statusColor = switch (status) {
      'active' => const Color(0xFF10B981),
      'pending' => const Color(0xFFF59E0B),
      'expired' || 'cancelled' => colors.error,
      _ => colors.onSurfaceVariant,
    };
    final statusLabel = switch (status) {
      'active' => 'abonnement.status_active'.tr,
      'pending' => 'abonnement.status_pending'.tr,
      'expired' => 'abonnement.status_expired'.tr,
      'cancelled' => 'abonnement.status_cancelled'.tr,
      _ => entry.status,
    };

    return Container(
      padding: EdgeInsets.all(r.space(16)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: r.widthOf(42),
            height: r.heightOf(42),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: colors.onPrimaryContainer,
              size: r.iconSize(21),
            ),
          ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.planName.isEmpty
                      ? 'abonnement.title'.tr
                      : entry.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    r.fontSize(15),
                    weight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: r.space(5)),
                Text(
                  [
                    if (entry.startsAt != null)
                      '${'abonnement.history_start'.tr} ${_formatDate(entry.startsAt!)}',
                    if (entry.endsAt != null)
                      '${'abonnement.history_end'.tr} ${_formatDate(entry.endsAt!)}',
                  ].join(' · '),
                  style: AppTextStyles.body(
                    r.fontSize(12),
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: r.space(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.space(9),
              vertical: r.space(5),
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(r.radius(20)),
            ),
            child: Text(
              statusLabel,
              style: AppTextStyles.body(
                r.fontSize(11),
                weight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.space(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: r.iconSize(44),
              color: colors.onSurfaceVariant,
            ),
            SizedBox(height: r.space(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                r.fontSize(14),
                color: colors.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: r.space(12)),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
