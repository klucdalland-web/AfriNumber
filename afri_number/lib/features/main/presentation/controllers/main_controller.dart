import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../country_search/presentation/views/country_search_tab.dart';
import '../../../dashboard/presentation/views/dashboard_tab.dart';
import '../../../connectivity/presentation/views/connectivity_tab.dart';
import '../../../history/presentation/views/history_tab.dart';
import '../../../profile/presentation/views/profile_tab.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<Widget> pages = const [
    DashboardPage(),
    CountrySearchPage(),
    ConnectivityTab(),
    HistoryTab(),
    ProfileTab(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}