import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue de réinitialisation du mot de passe : orchestre uniquement la mise
/// en page.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
              AuthHeader(moduleLabel: 'Vérification', showBackButton: true),
              SizedBox(height: r.space(8)),
              const ResetPasswordForm(),
              SizedBox(height: r.space(40)),
            ],
          ),
        ),
      ),
    );
  }
}
