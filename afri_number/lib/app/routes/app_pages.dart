import 'package:get/get.dart';
import '../bindings/account_tabs_binding.dart';
import '../../features/auth/presentation/views/auth_feedback_connexion_page.dart';
import '../../features/auth/presentation/views/auth_feedback_inscription_page.dart';
import '../../features/auth/presentation/views/forgot_password_page.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/otp_verification_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/auth/presentation/views/reset_password_page.dart';
import '../../features/main/presentation/controllers/main_controller.dart';
import '../../features/main/presentation/views/main_page.dart';
import '../../features/splash/presentation/views/splash_page.dart';
import '../../features/welcome/presentation/views/welcome_page.dart';
import 'app_routes.dart';

/// Binding local à la route /main — injecte MainController proprement.
class _MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    AccountTabsBinding().dependencies();
  }
}

class AppPages {
  AppPages._();

  /// La route initiale pointe toujours vers le SplashScreen.
  /// Le SplashController décide ensuite : /main si connecté, /welcome sinon.
  static String get initialRoute => AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = [
    // ── Splash ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),

    // ── Onboarding ──────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
    ),

    // ── Auth ────────────────────────────────────────────────────────────────
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

    // ── Main (shell authentifié avec BottomNavBar) ───────────────────────────
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: _MainBinding(),
    ),
  ];
}
