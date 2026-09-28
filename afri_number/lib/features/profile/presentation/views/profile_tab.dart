import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _confirmSignOut(BuildContext context, ProfileController controller) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Se déconnecter ?',
          style: GoogleFonts.zillaSlab(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Vous devrez vous reconnecter pour accéder à vos numéros virtuels.',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Annuler',
              style: GoogleFonts.ibmPlexSans(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Se déconnecter',
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
    final controller = Get.put(ProfileController());
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
                          label: 'Numéro de téléphone',
                          value: profile.phoneNumber,
                          trailing: ProfileRow.chevron(context),
                        ),
                        ProfileRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'Email',
                          value: profile.email,
                          trailing: ProfileRow.chevron(context),
                        ),
                        ProfileRow(
                          leading: CountryFlag(code: profile.countryCode, size: 24),
                          label: 'Pays de résidence',
                          value: profile.countryName,
                          trailing: ProfileRow.chevron(context),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space(24)),

                    // Section Title: Paramètres du compte
                    Text(
                      'Paramètres du compte',
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
                          label: 'Notifications',
                          value: notifications ? 'Activé' : 'Désactivé',
                          trailing: OutlineToggleIcon(on: notifications),
                          onTap: ctrl.toggleNotifications,
                        ),
                        ProfileRow(
                          icon: isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          label: 'Thème de l\'application',
                          value: isDarkMode ? 'Mode Sombre' : 'Mode Clair',
                          trailing: OutlineToggleIcon(on: isDarkMode),
                          onTap: ctrl.toggleTheme,
                        ),
                        ProfileRow(
                          leading: const CountryFlag(code: 'FR', size: 24),
                          label: 'Langue',
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
