import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Bouton carré arrondi rose en haut à droite (déconnexion).
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(r.u(18));

    return Semantics(
      button: true,
      label: 'profile.logout'.tr,
      child: Material(
        color: colors.errorContainer,
        borderRadius: radius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: radius,
          child: SizedBox(
            width: r.u(50),
            height: r.u(50),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: r.u(22),
                      height: r.u(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colors.onErrorContainer,
                      ),
                    )
                  : Icon(
                      Icons.meeting_room_outlined,
                      size: r.u(24),
                      color: colors.onErrorContainer,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
