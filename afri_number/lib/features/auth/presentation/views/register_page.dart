import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue d'inscription : orchestre uniquement la mise en page (Scaffold +
/// en-tête). Le contenu métier (champs, validation, soumission) vit dans
/// [RegisterForm].
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pad(h: 24, v: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(moduleLabel: 'auth.module_register'.tr),
              SizedBox(height: r.space(12)),
              const RegisterForm(),
              SizedBox(height: r.space(24)),
            ],
          ),
        ),
      ),
    );
  }
}
