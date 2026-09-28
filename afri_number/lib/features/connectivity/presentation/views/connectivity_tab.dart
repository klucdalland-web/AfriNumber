import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/connectivity_controller.dart';
import '../../data/repositories/mock_connectivity_repository.dart';
import '../widgets/plan_tile.dart';
import '../widgets/service_tile.dart';
import '../widgets/zero_data_card.dart';

class ConnectivityTab extends StatelessWidget {
  const ConnectivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ConnectivityController>()
        ? Get.find<ConnectivityController>()
        : Get.put(ConnectivityController(MockConnectivityRepository()));

    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          final empty = controller.services.isEmpty && controller.plans.isEmpty;

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
                  // Header
                  Text(
                    'Connectivité',
                    style: GoogleFonts.zillaSlab(
                      fontSize: r.fontSize(24),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: r.space(4)),
                  Text(
                    'Gérez vos services de connectivité et restez joignable partout.',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(13),
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),

                  SizedBox(height: r.space(20)),

                  if (controller.isLoading.value && empty)
                    Padding(
                      padding: EdgeInsets.only(top: r.space(60)),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                        ),
                      ),
                    )
                  else if (controller.errorMessage.isNotEmpty && empty)
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Zero Data Banner Card
                    ZeroDataCard(
                      enabled: controller.zeroDataEnabled.value,
                      onChanged: controller.toggleZeroData,
                    ),

                    SizedBox(height: r.space(24)),

                    // Mes services actifs
                    Text(
                      'Mes services actifs',
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: r.space(12)),
                    for (final service in controller.services) ...[
                      ServiceTile(service: service),
                      SizedBox(height: r.space(10)),
                    ],

                    SizedBox(height: r.space(20)),

                    // Forfaits disponibles
                    Text(
                      'Forfaits disponibles',
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: r.space(12)),
                    for (final plan in controller.plans) ...[
                      PlanTile(
                        plan: plan,
                        onTap: () {
                          Get.snackbar(
                            'Forfait sélectionné',
                            '${plan.name} - ${plan.price} Ar',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      SizedBox(height: r.space(10)),
                    ],
                  ],
                  SizedBox(height: r.space(20)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
