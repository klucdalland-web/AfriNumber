import 'package:get/get.dart';

import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
//import '../../features/dashboard/presentation/views/dashboard_page.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/welcome/presentation/views/welcome_page.dart';
import '../../features/messages/presentation/controllers/messages_controller.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/controllers/notifications_controller.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.welcome;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(HomeController.new);
      }),
    ),
    
    GetPage(
      name: AppRoutes.messages,
      page: () => const MessagesPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MessagesController>(MessagesController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationsController>(NotificationsController.new);
      }),
    ),
  ];
}
