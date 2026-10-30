import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Vue de connexion : scroll pour que le clavier ne masque pas le formulaire.
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.space(24),
                    vertical: r.space(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(moduleLabel: 'auth.module_login'.tr),
                      SizedBox(height: r.space(12)),
                      const LoginForm(),
                      SizedBox(height: r.space(16)),
                    ],
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
