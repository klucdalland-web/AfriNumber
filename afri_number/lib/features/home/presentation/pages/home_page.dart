import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../models/quick_action_data.dart';
import '../widgets/balance_card.dart';
import '../widgets/deposit_section.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_section.dart';

/// Écran « Accueil » (Figma : Accueil).
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Actions rapides (les callbacks sont branchés sur le contrôleur UI).
    final actions = <QuickActionData>[
      const QuickActionData(label: 'Acheter un numéro', icon: Icons.call_outlined),
      const QuickActionData(label: 'Recharger', icon: Icons.inbox_outlined),
      QuickActionData(
        label: 'SMS',
        icon: Icons.drafts_outlined,
        onTap: controller.openMessages,
      ),
      const QuickActionData(label: 'Historique', icon: Icons.history_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                country: HomeController.mockCountry,
                countryFlagAsset: HomeController.mockCountryFlag,
                onNotificationsTap: controller.openNotifications,
              ),
              const SizedBox(height: 34),
              Obx(
                () => BalanceCard(
                  data: HomeController.mockWallet,
                  isBalanceVisible: controller.isBalanceVisible.value,
                  onToggleVisibility: controller.toggleBalanceVisibility,
                ),
              ),
              const SizedBox(height: 42),
              QuickActionsSection(actions: actions),
              const SizedBox(height: 24),
              const DepositSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => HomeBottomNavBar(
          currentIndex: controller.currentTab.value,
          onTap: controller.selectTab,
        ),
      ),
    );
  }
}
