import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../widgets/widgets.dart';

/// Écran "Inscription Réussie !" — `Auth/FeedBack/Inscription` dans la maquette.
class AuthFeedbackInscriptionPage extends StatelessWidget {
  const AuthFeedbackInscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackView(
      title: 'Inscription Réussie !',
      subtitle: 'Bienvenue parmi nous ! Votre compte est prêt, vous pouvez maintenant commencer.',
      onContinue: () => Get.offAllNamed(AppRoutes.main),
    );
  }
}
