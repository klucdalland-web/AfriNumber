import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../models/wallet_card_data.dart';

/// État UI de l'écran Accueil (visibilité du solde, onglet actif).
class HomeController extends GetxController {
  /// Données fictives — à remplacer par un use case / repository.
  static const WalletCardData mockWallet = WalletCardData(
    currencyName: 'Dollar américain',
    currencySymbol: '£',
    balance: 12289.98,
    virtualNumberMasked: '**** 9548',
    expiry: '25/08',
    flagAsset: 'assets/images/flags/usd.png',
  );

  static const String mockCountry = 'Madagascar';
  static const String mockCountryFlag = 'assets/images/flags/mg.png';

  final RxBool isBalanceVisible = true.obs;
  final RxInt currentTab = 0.obs;

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  void selectTab(int index) => currentTab.value = index;

  void openNotifications() => Get.toNamed(AppRoutes.notifications);

  void openMessages() => Get.toNamed(AppRoutes.messages);
}
