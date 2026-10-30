import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Bouton carré arrondi rose en haut à droite (déconnexion).
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

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
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            width: r.u(50),
            height: r.u(50),
            child: Icon(
              Icons.meeting_room_outlined,
              size: r.u(24),
              color: colors.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
