import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../widgets/widgets.dart';

/// Écran "Connexion Réussie !" — `Auth/FeedBack/Connexion` dans la maquette.
class AuthFeedbackConnexionPage extends StatelessWidget {
  const AuthFeedbackConnexionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackView(
      title: 'Connexion Réussie !',
      subtitle: 'Bienvenue à nouveau ! Vous êtes maintenant connecté à votre compte.',
      onContinue: () => Get.offAllNamed(AppRoutes.dashboard),
    );
  }
}
