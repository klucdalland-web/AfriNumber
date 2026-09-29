import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import 'auth_header.dart';

enum SuccessVariant { login, register }

class SuccessConfirmationPage extends StatelessWidget {
  const SuccessConfirmationPage({
    super.key,
    required this.variant,
    this.onContinue,
  });

  final SuccessVariant variant;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isLogin = variant == SuccessVariant.login;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        AuthHeader(
                          moduleLabel: isLogin
                              ? 'auth.module_login'.tr
                              : 'auth.module_register'.tr,
                        ),
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
                                isLogin
                                    ? 'feedback.login_success_title'.tr
                                    : 'feedback.register_success_title'.tr,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: r.fontSize(24),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: r.space(12)),
                              Text(
                                isLogin
                                    ? 'feedback.login_success_subtitle'.tr
                                    : 'feedback.register_success_subtitle'.tr,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: r.space(32)),
                              SizedBox(
                                width: double.infinity,
                                height: r.heightOf(56),
                                child: ElevatedButton(
                                  onPressed: onContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.onSurface,
                                    foregroundColor: theme.colorScheme.surface,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        r.radius(28),
                                      ),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: r.fontSize(16),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  child: Text('feedback.continue'.tr),
                                ),
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
