import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/language_selector_sheet.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../abonnement/presentation/controllers/abonnement_controller.dart';
import '../../../abonnement/presentation/widgets/skeleton.dart';
import '../controllers/profile_controller.dart';
import '../widgets/country_flag.dart';
import '../widgets/outline_toggle_icon.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_group_card.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_row.dart';
import '../widgets/profile_stats_row.dart';

/// Vue de l'onglet Profil.
/// Affiche les données utilisateur récupérées depuis l'API (`/auth/user` / `/auth/me`)
/// et permet de modifier les préférences de l'application (thème, langue, notifications).
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  /// Boîte de dialogue de confirmation de déconnexion.
  Future<void> _confirmSignOut(
    BuildContext context,
    ProfileController controller,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'profile.logout_title'.tr,
          style: GoogleFonts.zillaSlab(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'profile.logout_body'.tr,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'common.cancel'.tr,
              style: GoogleFonts.ibmPlexSans(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'profile.logout'.tr,
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final abonnementController = Get.find<AbonnementController>();
    final localeController = Get.find<LocaleController>();
    final r = context.responsive;
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          init: controller,
          builder: (ctrl) {
            return Obx(() {
              if (ctrl.isRefreshing.value ||
                  abonnementController.isLoading.value) {
                return const _ProfilePageSkeleton();
              }

              final profile = ctrl.profile.value;
              final notifications = ctrl.notificationsEnabled.value;
              final isDarkMode = ctrl.isDark;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: r.space(20),
                  vertical: r.space(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── En-tête : Bouton déconnexion, Avatar, Nom, Pseudo & Statuts ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            const ProfileAvatar(size: 96),
                            SizedBox(height: r.space(12)),
                            // Nom de l'utilisateur connecté ("name")
                            Text(
                              profile.fullName,
                              style: GoogleFonts.zillaSlab(
                                fontSize: r.fontSize(22),
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: r.space(2)),
                            // Identifiant pseudo généré à partir de l'e-mail
                            Text(
                              profile.username,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(14),
                                fontWeight: FontWeight.w400,
                                color: subtextColor,
                              ),
                            ),
                            SizedBox(height: r.space(8)),
                            // Badge dynamique affichant les attributs `statut` et `status_valide`
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.space(10),
                                vertical: r.space(4),
                              ),
                              decoration: BoxDecoration(
                                color: profile.isActive
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(r.radius(20)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: profile.isActive
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: r.space(6)),
                                  Text(
                                    '${profile.status ?? "actif"} • ${profile.validationStatus ?? "non_valide"}',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: r.fontSize(12),
                                      fontWeight: FontWeight.w600,
                                      color: profile.isActive
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Bouton de déconnexion en haut à droite
                        ProfileLogoutButton(
                          onPressed: () => _confirmSignOut(context, ctrl),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(20)),

                    // ── Rangée de statistiques visuelles ──
                    Obx(
                      () => ProfileStatsRow(
                        activeNumbers: 1,
                        planName: _currentPlanLabel(abonnementController),
                        countriesCount: 1,
                      ),
                    ),

                    SizedBox(height: r.space(24)),

                    // ── Titre de section : Coordonnées personnelles ──
                    Text(
                      'profile.personal_info'.tr,
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: r.space(12)),

                    // ── Carte 1 : Coordonnées (nom, phone_number, email, pays) ──
                    ProfileGroupCard(
                      children: [
                        ProfileRow(
                          icon: Icons.person_outline_rounded,
                          label: 'profile.account_name'.tr,
                          value: profile.fullName,
                        ),
                        ProfileRow(
                          icon: Icons.call_outlined,
                          label: 'profile.phone'.tr,
                          value: profile.phoneNumber ?? 'Non renseigné',
                          trailing: ProfileRow.chevron(context),
                        ),
                        ProfileRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'profile.email'.tr,
                          value: profile.email ?? 'Non renseigné',
                          trailing: ProfileRow.chevron(context),
                        ),
                        ProfileRow(
                          leading: CountryFlag(
                            code: profile.countryCode,
                            size: 24,
                          ),
                          label: 'profile.country'.tr,
                          value: '${profile.countryName} (${profile.countryCallingCode})',
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(24)),

                    // ── Titre de section : Compte & Organisation ──
                    Text(
                      'profile.account_section'.tr,
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: r.space(12)),

                    // ── Carte 2 : Type d'utilisateur, Organisation & Statuts API ──
                    ProfileGroupCard(
                      children: [
                        // Navigation vers la page de gestion des abonnements
                        ProfileRow(
                          icon: Icons.card_membership_rounded,
                          label: 'profile.manage_subscription'.tr,
                          value: '',
                          trailing: ProfileRow.chevron(context),
                          onTap: () => Get.toNamed(AppRoutes.abonnement),
                        ),
                        Obx(
                          () => ProfileRow(
                            icon: Icons.workspace_premium_outlined,
                            label: 'profile.current_plan'.tr,
                            value: _currentPlanLabel(abonnementController),
                          ),
                        ),
                        ProfileRow(
                          icon: Icons.badge_outlined,
                          label: 'profile.user_type'.tr,
                          value: '${profile.userTypeLabel} (${profile.userTypeCode})',
                        ),
                        ProfileRow(
                          icon: Icons.business_rounded,
                          label: 'profile.organisation'.tr,
                          value: profile.organisationName,
                        ),
                        ProfileRow(
                          icon: Icons.verified_user_outlined,
                          label: 'profile.account_status'.tr,
                          value: profile.status ?? 'actif',
                        ),
                        ProfileRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'profile.validation'.tr,
                          value: profile.validationStatus ?? 'non_valide',
                          trailing: ProfileRow.chevron(context),
                          onTap: () async {
                            await Get.toNamed(AppRoutes.kyc);
                            await ctrl.refreshProfile();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(24)),

                    // ── Titre de section : Paramètres de l'application ──
                    Text(
                      'profile.settings_title'.tr,
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: r.space(12)),

                    // ── Carte 3 : Préférences (Notifications, Thème, Langue) ──
                    ProfileGroupCard(
                      children: [
                        ProfileRow(
                          icon: Icons.notifications_none_rounded,
                          label: 'profile.notifications'.tr,
                          value: notifications
                              ? 'common.on'.tr
                              : 'common.off'.tr,
                          trailing: OutlineToggleIcon(on: notifications),
                          onTap: ctrl.toggleNotifications,
                        ),
                        ProfileRow(
                          icon: isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          label: 'profile.theme'.tr,
                          value: isDarkMode
                              ? 'common.theme_dark'.tr
                              : 'common.theme_light'.tr,
                          trailing: OutlineToggleIcon(on: isDarkMode),
                          onTap: ctrl.toggleTheme,
                        ),
                        ProfileRow(
                          leading: CountryFlag(
                            code: localeController.isFrench ? 'FR' : 'GB',
                            size: 24,
                          ),
                          label: 'profile.language'.tr,
                          value: localeController.isFrench
                              ? 'Français'
                              : 'English',
                          trailing: ProfileRow.chevron(context),
                          onTap: () => showLanguageSelector(context),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(32)),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

String _currentPlanLabel(AbonnementController controller) {
  final planId = controller.currentPlanId.value;
  for (final plan in controller.plans) {
    if (plan.id == planId) return plan.name;
  }
  return controller.isLoading.value
      ? 'abonnement.loading_plan'.tr
      : 'abonnement.no_plan'.tr;
}

class _ProfilePageSkeleton extends StatelessWidget {
  const _ProfilePageSkeleton();

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    Widget sectionTitle() => SkeletonBox(
      width: r.space(150),
      height: r.space(20),
      radius: r.radius(6),
    );

    Widget card(int rows) => Container(
      padding: EdgeInsets.all(r.space(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: List.generate(rows, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: r.space(9)),
            child: Row(
              children: [
                SkeletonBox(
                  width: r.space(26),
                  height: r.space(26),
                  radius: r.radius(13),
                ),
                SizedBox(width: r.space(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: r.space(index.isEven ? 112 : 82),
                        height: r.space(12),
                        radius: r.radius(5),
                      ),
                      SizedBox(height: r.space(6)),
                      SkeletonBox(
                        width: r.space(index.isEven ? 88 : 126),
                        height: r.space(10),
                        radius: r.radius(5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );

    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: r.space(20),
          vertical: r.space(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: r.space(40),
                  height: r.space(40),
                  radius: r.radius(20),
                ),
                Column(
                  children: [
                    SkeletonBox(
                      width: r.space(96),
                      height: r.space(96),
                      radius: r.radius(48),
                    ),
                    SizedBox(height: r.space(12)),
                    SkeletonBox(
                      width: r.space(150),
                      height: r.space(22),
                      radius: r.radius(6),
                    ),
                    SizedBox(height: r.space(7)),
                    SkeletonBox(
                      width: r.space(110),
                      height: r.space(14),
                      radius: r.radius(5),
                    ),
                    SizedBox(height: r.space(10)),
                    SkeletonBox(
                      width: r.space(120),
                      height: r.space(24),
                      radius: r.radius(14),
                    ),
                  ],
                ),
                SkeletonBox(
                  width: r.space(40),
                  height: r.space(40),
                  radius: r.radius(20),
                ),
              ],
            ),
            SizedBox(height: r.space(24)),
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.space(8)),
                    child: Column(
                      children: [
                        SkeletonBox(
                          width: r.space(68),
                          height: r.space(20),
                          radius: r.radius(5),
                        ),
                        SizedBox(height: r.space(7)),
                        SkeletonBox(
                          width: r.space(52),
                          height: r.space(12),
                          radius: r.radius(5),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: r.space(28)),
            sectionTitle(),
            SizedBox(height: r.space(12)),
            card(4),
            SizedBox(height: r.space(24)),
            sectionTitle(),
            SizedBox(height: r.space(12)),
            card(6),
            SizedBox(height: r.space(24)),
            sectionTitle(),
            SizedBox(height: r.space(12)),
            card(3),
            SizedBox(height: r.space(32)),
          ],
        ),
      ),
    );
  }
}
