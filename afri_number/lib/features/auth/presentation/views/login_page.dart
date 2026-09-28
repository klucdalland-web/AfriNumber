import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue de connexion : ajustée sur une seule vue dynamique sans scroll,
/// sauf pour les petits écrans.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.space(24),
                      vertical: r.space(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(moduleLabel: 'Connexion'),
                        SizedBox(height: r.space(12)),
                        const Expanded(child: LoginForm()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
