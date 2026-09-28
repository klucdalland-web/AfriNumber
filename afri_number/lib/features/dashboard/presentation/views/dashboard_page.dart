import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final r = context.responsive;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: r.space(20),
            vertical: r.space(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (AfriNumber. + Country Pill + Notification Bell + Profile Avatar)
              Obx(
                () => DashboardHeader(
                  scale: r.scale,
                  country: controller.userCountry.value,
                  onNotificationTap: () {
                    Get.snackbar(
                      'Notifications',
                      'Aucune nouvelle notification pour le moment.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  onProfileTap: () {
                    Get.snackbar(
                      'Profil',
                      'Ouverture de votre profil utilisateur.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),

              SizedBox(height: r.space(20)),

              // 2. VIRTUAL CARD (Dollar américain / Livre Sterling balance, eye toggle, virtual number, expiry)
              Obx(
                () => VirtualCard(
                  scale: r.scale,
                  currencyName: controller.currencyName.value,
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
                onBuyNumberTap: () {
                  Get.snackbar('Action', 'Acheter un numéro');
                },
                onRechargeTap: () {
                  Get.snackbar('Action', 'Recharger');
                },
                onSmsTap: () {
                  Get.snackbar('Action', 'SMS');
                },
                onHistoryTap: () {
                  Get.snackbar('Action', 'Historique');
                },
              ),

              SizedBox(height: r.space(24)),

              // 4. TRANSACTIONS RÉCENTES (Replaces Dépôt section)
              Obx(
                () => RecentTransactionsSection(
                  scale: r.scale,
                  transactions: controller.recentTransactions.toList(),
                  onViewAllTap: () {
                    Get.snackbar('Historique', 'Affichage de toutes les transactions');
                  },
                ),
              ),

              SizedBox(height: r.space(24)),

              // 5. OFFRES RECOMMANDÉES (Offres par pays)
              Obx(
                () => RecommendedOffersSection(
                  scale: r.scale,
                  offers: controller.recommendedOffers.toList(),
                  onViewAllTap: () {
                    Get.snackbar('Offres', 'Affichage de toutes les offres');
                  },
                  onOfferTap: (offer) {
                    Get.snackbar('Offre', 'Acheter offre ${offer.country}');
                  },
                ),
              ),

              SizedBox(height: r.space(20)),
            ],
          ),
        ),
      ),
    );
  }
}
