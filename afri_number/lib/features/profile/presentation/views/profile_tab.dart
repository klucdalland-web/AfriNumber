import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/language_selector_sheet.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/country_flag.dart';
import '../widgets/outline_toggle_icon.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_group_card.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_row.dart';
import '../widgets/profile_stats_row.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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
                    // Header: Logout button top-right + Avatar + Identity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            const ProfileAvatar(size: 96),
                            SizedBox(height: r.space(12)),
                            Text(
                              profile.fullName,
                              style: GoogleFonts.zillaSlab(
                                fontSize: r.fontSize(22),
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: r.space(2)),
                            Text(
                              profile.username,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: r.fontSize(14),
                                fontWeight: FontWeight.w400,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        ProfileLogoutButton(
                          onPressed: () => _confirmSignOut(context, ctrl),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(20)),

                    // Stats Row
                    ProfileStatsRow(
                      activeNumbers: profile.activeNumbers,
                      planName: profile.planName,
                      countriesCount: profile.countriesCount,
                    ),

                    SizedBox(height: r.space(24)),

                    // Coordonnées Group Card
                    ProfileGroupCard(
                      children: [
                        ProfileRow(
                          icon: Icons.call_outlined,
                          label: 'profile.phone'.tr,
                          value: profile.phoneNumber ?? '+xxxxxxxxxxxx',
                          trailing: ProfileRow.chevron(context),
                        ),
                        ProfileRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'profile.email'.tr,
                          value: profile.email ?? 'JeanDuBois.arthur@example.com',
                          trailing: ProfileRow.chevron(context),
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

                    SizedBox(height: r.space(24)),

                    // Section Title: Paramètres du compte
                    Text(
                      'profile.settings_title'.tr,
                      style: GoogleFonts.zillaSlab(
                        fontSize: r.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: r.space(12)),

                    // Settings Group Card
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
                          leading: const CountryFlag(code: 'FR', size: 24),
                          label: 'profile.language'.tr,
                          value: ctrl.language.value,
                          trailing: ProfileRow.chevron(context),
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
