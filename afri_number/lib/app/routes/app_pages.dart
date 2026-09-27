import 'package:get/get.dart';

import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/otp_verification_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/auth/presentation/views/forgot_password_page.dart';
import '../../features/auth/presentation/views/reset_password_page.dart';
import '../../features/auth/presentation/views/auth_feedback_connexion_page.dart';
import '../../features/auth/presentation/views/auth_feedback_inscription_page.dart';
import '../../features/welcome/presentation/views/welcome_page.dart';
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
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.authFeedbackConnexion,
      page: () => const AuthFeedbackConnexionPage(),
    ),
    GetPage(
      name: AppRoutes.authFeedbackInscription,
      page: () => const AuthFeedbackInscriptionPage(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
    ),
  ];
}
