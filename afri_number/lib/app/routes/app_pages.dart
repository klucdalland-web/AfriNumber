import 'package:get/get.dart';

import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/otp_verification_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/welcome/presentation/views/welcome_page.dart';
import '../../features/auth/presentation/widgets/success_confirmation.dart';
import '../../features/dashboard/presentation/views/dashboard_page.dart';
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
      name: AppRoutes.otpVerification,
      page: () => const OTPVerificationPage(),
    ),
    GetPage(
      name: AppRoutes.successConfirmation,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final variant = args['variant'] as String? ?? 'login';
        return SuccessConfirmationPage(
          variant: variant == 'register'
              ? SuccessVariant.register
              : SuccessVariant.login,
          onContinue: () => Get.offAllNamed(AppRoutes.dashboard),
        );
      },
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
    ),
  ];
}