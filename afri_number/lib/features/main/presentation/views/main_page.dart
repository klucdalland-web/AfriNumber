import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../widgets/main_bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // putIfAbsent : crée le controller s'il n'existe pas encore,
    // sinon réutilise l'instance existante (évite le double-register).
    final controller = Get.put(MainController(), permanent: false);

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(),
    );
  }
}
