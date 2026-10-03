import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/country_flag.dart';
import '../widgets/outline_toggle_icon.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_group_card.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_row.dart';
import '../widgets/profile_scale.dart';
import '../widgets/profile_stats_row.dart';




class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour accéder à votre compte.',
        ),
        actions: [
          AppButton.text(
            label: 'Annuler',
            onPressed: () => Navigator.of(dialogContext).pop(false),
            foregroundColor: AppColors.ink,
          ),
          AppButton.text(
            label: 'Se déconnecter',
            onPressed: () => Navigator.of(dialogContext).pop(true),
            foregroundColor: AppColors.logoutForeground,
          ),
        ],
      ),
    );
    if (confirmed == true) controller.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final profile = controller.profile.value;
          final notifications = controller.notificationsEnabled.value;
          final light = controller.isLightTheme.value;

          return ListView(
            padding: EdgeInsets.only(top: r.u(12), bottom: r.u(120)),
            children: [
              // En-tête : bouton de déconnexion + avatar + identité.
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                    children: [
                      SizedBox(height: r.u(40)),
                      ProfileAvatar(size: 128),
                      SizedBox(height: r.u(8)),
                      Text(
                        profile.fullName,
                        style: AppTextStyles.screenTitle(r.f(26)).copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        profile.username,
                        style: AppTextStyles.sectionTitle(r.f(18)).copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.handle,
                          height: 1.2,
                          fontFeatures: const [FontFeature.oldstyleFigures()],
                        ),
                      ),
                    ],
                  ),
                  ),
                  Positioned(
                    top: 0,
                    right: r.u(29),
                    child: ProfileLogoutButton(
                      onPressed: () => _confirmSignOut(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.u(16)),
              ProfileStatsRow(
                activeNumbers: profile.activeNumbers,
                planName: profile.planName,
                countriesCount: profile.countriesCount,
                onTapAbonnement: () => Get.toNamed(AppRoutes.abonnement),
              ),
              SizedBox(height: r.u(26)),

              // Coordonnées.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.u(27)),
                child: ProfileGroupCard(
                  children: [
                    ProfileRow(
                      icon: Icons.call_outlined,
                      label: 'Numéro de téléphone',
                      value: profile.phoneNumber,
                      trailing: ProfileRow.chevron(context),
                    ),
                    ProfileRow(
                      icon: Icons.drafts_outlined,
                      label: 'Email',
                      value: profile.email,
                      trailing: ProfileRow.chevron(context),
                    ),
                    ProfileRow(
                      leading: CountryFlag(code: profile.countryCode),
                      label: 'Pays',
                      value: profile.countryName,
                      trailing: ProfileRow.chevron(context),
                    ),
                  ],
                ),
              ),

              // Paramètres du compte.
              Padding(
                padding: EdgeInsets.fromLTRB(r.u(49), r.u(20), r.u(27), r.u(17)),
                child: Text(
                  'Paramètres du compte',
                  style: AppTextStyles.sectionTitle(r.f(18)).copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.u(27)),
                child: ProfileGroupCard(
                  children: [
                    ProfileRow(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      value: notifications ? 'Activé' : 'Désactivé',
                      trailing: OutlineToggleIcon(on: notifications),
                      onTap: controller.toggleNotifications,
                    ),
                    ProfileRow(
                      icon: light
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      label: 'Thème',
                      value: light ? 'Clair' : 'Sombre',
                      trailing: OutlineToggleIcon(on: light),
                      onTap: controller.toggleTheme,
                    ),
                    ProfileRow(
                      leading: const CountryFlag(code: 'FR'),
                      label: 'Langue',
                      value: controller.language.value,
                      trailing: ProfileRow.chevron(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
