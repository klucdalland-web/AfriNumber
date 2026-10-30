import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_tile.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    final r = context.responsive;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final groups = controller.groups;
          final loadingFirst =
              controller.isLoading.value && controller.entries.isEmpty;

          return RefreshIndicator(
            onRefresh: controller.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: r.space(20),
                vertical: r.space(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  Text(
                    'nav.history'.tr,
                    style: GoogleFonts.zillaSlab(
                      fontSize: r.fontSize(24),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    'history.subtitle'.tr,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(13),
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),

                  SizedBox(height: r.space(16)),

                  // Filter Chips Bar
                  HistoryFilterBar(
                    selected: controller.filter.value,
                    onSelected: controller.selectFilter,
                  ),

                  SizedBox(height: r.space(20)),

                  if (loadingFirst)
                    Padding(
                      padding: EdgeInsets.only(top: r.space(60)),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else if (controller.errorMessage.isNotEmpty &&
                      controller.entries.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: r.space(40)),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              controller.errorMessage.value,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(14),
                                color: subtextColor,
                              ),
                            ),
                            SizedBox(height: r.space(12)),
                            ElevatedButton(
                              onPressed: controller.load,
                              child: Text('common.retry'.tr),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (groups.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: r.space(60)),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: r.iconSize(48),
                              color: subtextColor,
                            ),
                            SizedBox(height: r.space(12)),
                            Text(
                              'history.empty'.tr,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(15),
                                fontWeight: FontWeight.w500,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    for (final group in groups) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          top: r.space(8),
                          bottom: r.space(10),
                        ),
                        child: Text(
                          group.label,
                          style: GoogleFonts.zillaSlab(
                            fontSize: r.fontSize(16),
                            fontWeight: FontWeight.w700,
                            color: subtextColor,
                          ),
                        ),
                      ),
                      for (final entry in group.entries) ...[
                        HistoryTile(entry: entry),
                        SizedBox(height: r.space(10)),
                      ],
                      SizedBox(height: r.space(12)),
                    ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
