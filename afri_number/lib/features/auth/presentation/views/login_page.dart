import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue de connexion : orchestre uniquement la mise en page (Scaffold +
/// en-tête). Le contenu métier (champs, validation, soumission) vit dans
/// [LoginForm].
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pad(h: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: r.space(20)),
              AuthHeader(moduleLabel: 'Connexion'),
              SizedBox(height: r.space(8)),
              const LoginForm(),
              SizedBox(height: r.space(40)),
            ],
          ),
        ),
      ),
    );
  }
}
