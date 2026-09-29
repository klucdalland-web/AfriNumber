import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/offer_item.dart';
import '../../domain/models/transaction_item.dart';

class DashboardController extends GetxController {
  final RxString userCountry = 'Madagascar'.obs;
  final RxString currencyName = 'Dollar américain'.obs;
  final RxString balanceAmount = '£ 12,289.98'.obs;
  final RxString virtualNumber = '**** 9548'.obs;
  final RxString expirationDate = '25/08'.obs;
  final RxBool isBalanceHidden = false.obs;

  final RxList<TransactionItem> recentTransactions = <TransactionItem>[].obs;
  final RxList<OfferItem> recommendedOffers = <OfferItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
  }

  void toggleBalanceVisibility() {
    isBalanceHidden.value = !isBalanceHidden.value;
  }

  void _loadDashboardData() {
    recentTransactions.assignAll(const [
      TransactionItem(
        id: 'tx_1',
        title: 'Dépôt Mobile Money',
        subtitle: 'MVola · Aujourd\'hui',
        amount: '+25 000 Ar',
        isPositive: true,
        status: 'Réussi ✓',
        icon: Icons.south_west_rounded,
        iconBgColor: Color(0xFF10B981),
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Achat numéro',
        subtitle: 'États-Unis · Aujourd\'hui',
        amount: '-12 \$',
        isPositive: false,
        status: 'Réussi ✓',
        icon: Icons.phone_android_rounded,
        iconBgColor: Color(0xFF3B82F6),
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'Recharge numéro',
        subtitle: '+1 *** 9548 · Hier',
        amount: '-5 \$',
        isPositive: false,
        status: 'Réussi ✓',
        icon: Icons.bolt_rounded,
        iconBgColor: Color(0xFFF59E0B),
      ),
    ]);

    recommendedOffers.assignAll(const [
      OfferItem(
        id: 'off_1',
        country: 'États-Unis',
        title: 'Numéro international',
        startingPrice: '1.99 \$',
        countryIcon: Icons.public_rounded,
      ),
      OfferItem(
        id: 'off_2',
        country: 'Royaume-Uni',
        title: 'Numéro international',
        startingPrice: '2.49 \$',
        countryIcon: Icons.public_rounded,
      ),
      OfferItem(
        id: 'off_3',
        country: 'France',
        title: 'Numéro international',
        startingPrice: '2.99 \$',
        countryIcon: Icons.public_rounded,
      ),
    ]);
  }
}
