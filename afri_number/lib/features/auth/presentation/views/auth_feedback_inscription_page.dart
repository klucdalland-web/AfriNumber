import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/auth_navigation.dart';
import '../widgets/widgets.dart';

/// Écran "Inscription Réussie !" — `Auth/FeedBack/Inscription` dans la maquette.
class AuthFeedbackInscriptionPage extends StatelessWidget {
  const AuthFeedbackInscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackView(
      title: 'feedback.register_success_title'.tr,
      subtitle: 'feedback.register_success_subtitle'.tr,
      onContinue: AuthNavigation.goToHome,
    );
  }
}
