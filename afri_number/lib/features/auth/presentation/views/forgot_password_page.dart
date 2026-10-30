import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue "Mot de passe oublié" : orchestre uniquement la mise en page.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
              AuthHeader(moduleLabel: 'Récupération', showBackButton: true),
              SizedBox(height: r.space(8)),
              const ForgotPasswordForm(),
              SizedBox(height: r.space(40)),
            ],
          ),
        ),
      ),
    );
  }
}
