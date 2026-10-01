import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final r = context.responsive;
    void openTab(int index) => Get.find<MainController>().changePage(index);

    return AppScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadDashboardData,
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
                // 1. TOP HEADER (AfriNumber. + Country Pill + Notification Bell + Messages Icon)
                Obx(
                  () => DashboardHeader(
                    scale: r.scale,
                    country: controller.userCountry.value == 'Madagascar'
                        ? 'country.MG'.tr
                        : controller.userCountry.value,
                    onNotificationTap: () => Get.toNamed(AppRoutes.notifications),
                    onMessageTap: () => Get.toNamed(AppRoutes.messages),
                  ),
                ),

                Obx(() {
                  if (controller.isLoading.value &&
                      controller.recentTransactions.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: r.space(16)),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (controller.errorMessage.isNotEmpty &&
                      controller.recentTransactions.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: r.space(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'common.retry'.tr,
                            onPressed: controller.loadDashboardData,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: r.space(20)),

                // 2. VIRTUAL CARD (Dollar américain / Livre Sterling balance, eye toggle, virtual number, expiry)
                Obx(
                  () => VirtualCard(
                    scale: r.scale,
                    currencyName:
                        controller.currencyName.value == 'Dollar américain'
                        ? 'welcome.currency_usd'.tr
                        : controller.currencyName.value,
                    balance: controller.balanceAmount.value,
                    virtualNumber: controller.virtualNumber.value,
                    expirationDate: controller.expirationDate.value,
                    isBalanceHidden: controller.isBalanceHidden.value,
                    onToggleVisibility: controller.toggleBalanceVisibility,
                  ),
                ),

                SizedBox(height: r.space(24)),

                // 3. ACTIONS RAPIDES GRID (Acheter un numéro, Recharger, SMS, Historique)
                QuickActionsGrid(
                  scale: r.scale,
                  onBuyNumberTap: () => openTab(1),
                  onRechargeTap: () => openTab(2),
                  onSmsTap: () => Get.toNamed(AppRoutes.messages),
                  onHistoryTap: () => openTab(3),
                ),

                SizedBox(height: r.space(24)),

                // 4. TRANSACTIONS RÉCENTES (Replaces Dépôt section)
                Obx(
                  () => RecentTransactionsSection(
                    scale: r.scale,
                    transactions: controller.recentTransactions.toList(),
                    onViewAllTap: () => openTab(3),
                  ),
                ),

                SizedBox(height: r.space(24)),

                // 5. OFFRES RECOMMANDÉES (Offres par pays)
                Obx(
                  () => RecommendedOffersSection(
                    scale: r.scale,
                    offers: controller.recommendedOffers.toList(),
                    onViewAllTap: () => openTab(1),
                    onOfferTap: (offer) {
                      final countryKey = switch (offer.country) {
                        'États-Unis' => 'country.US',
                        'Royaume-Uni' => 'country.UK',
                        'France' => 'country.FR',
                        _ => null,
                      };
                      final countryName = countryKey == null
                          ? offer.country
                          : countryKey.tr;
                      Get.snackbar(
                        'dashboard.recommended_offers'.tr,
                        '${'dashboard.buy_offer'.tr} $countryName',
                      );
                    },
                  ),
                ),

                SizedBox(height: r.space(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
