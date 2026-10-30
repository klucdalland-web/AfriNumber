import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import 'auth_header.dart';

/// Vue de retour (feedback) générique — utilisée par les deux écrans de
/// succès de la maquette (`Auth/FeedBack/Connexion` et
/// `Auth/FeedBack/Inscription`). Ne connaît rien du login/register : elle
/// reçoit son titre, son sous-titre et l'action de son bouton "Poursuivre".
class AuthFeedbackView extends StatelessWidget {
  const AuthFeedbackView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onContinue,
    this.buttonLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback onContinue;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return AppScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: r.pad(h: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: r.space(20)),
                        AuthHeader(moduleLabel: title),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(r.space(32)),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(r.radius(28)),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: r.space(24),
                                offset: const Offset(0, 8),
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: r.iconSize(80),
                                height: r.iconSize(80),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: theme.colorScheme.surface,
                                  size: r.iconSize(40),
                                ),
                              ),
                              SizedBox(height: r.space(24)),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: r.fontSize(24),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: r.space(12)),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: r.space(32)),
                              AppButton.primary(
                                label: buttonLabel ?? 'feedback.continue'.tr,
                                onPressed: onContinue,
                                backgroundColor: theme.colorScheme.onSurface,
                                foregroundColor: theme.colorScheme.surface,
                                radius: r.radius(28),
                                height: r.heightOf(56),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(height: r.space(40)),
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
