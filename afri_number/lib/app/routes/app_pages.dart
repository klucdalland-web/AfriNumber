import 'package:get/get.dart';

import '../../features/abonnement/presentation/views/abonnement_page.dart';
import '../../features/kyc/kyc.dart';
import '../../features/auth/presentation/views/auth_feedback_connexion_page.dart';
import '../../features/auth/presentation/views/auth_feedback_inscription_page.dart';
import '../../features/auth/presentation/views/forgot_password_page.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/otp_verification_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/auth/presentation/views/reset_password_page.dart';
import '../../features/main/presentation/bindings/main_binding.dart';
import '../../features/main/presentation/views/main_page.dart';
import '../../features/messages/presentation/bindings/messages_binding.dart';
import '../../features/messages/presentation/views/messages_tab.dart';
import '../../features/notifications/presentation/bindings/notifications_binding.dart';
import '../../features/notifications/presentation/views/notifications_tab.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/views/splash_page.dart';
import '../../features/welcome/presentation/views/welcome_page.dart';
import '../middleware/kyc_gate_middleware.dart';
import 'app_routes.dart';

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
      binding: SplashBinding(),
    ),

    // ── Messages & Notifications ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.messages,
      page: () => const MessagesTab(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsTab(),
      binding: NotificationsBinding(),
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

    // ── Abonnement ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.abonnement,
      page: () => const AbonnementPage(),
    ),

    // ── Vérification d'identité ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.kyc,
      page: () => const KycPage(),
      binding: KycBinding(),
    ),

    // ── Main (shell authentifié avec BottomNavBar) ───────────────────────────
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
      middlewares: [KycGateMiddleware()],
    ),
  ];
}
