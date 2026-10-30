import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/auth_navigation.dart';
import '../widgets/widgets.dart';

/// Écran "Connexion Réussie !" — `Auth/FeedBack/Connexion` dans la maquette.
class AuthFeedbackConnexionPage extends StatelessWidget {
  const AuthFeedbackConnexionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackView(
      title: 'feedback.login_success_title'.tr,
      subtitle: 'feedback.login_success_subtitle'.tr,
      onContinue: AuthNavigation.goToHome,
    );
  }
}
