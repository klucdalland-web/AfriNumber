import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../country_search/presentation/views/country_search_page.dart';
import '../../../dashboard/presentation/views/dashboard_page.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<Widget> pages = const [
    DashboardPage(),
    CountrySearchPage(),
    _MockPage(icon: Icons.pie_chart_outline_rounded, label: 'Répartition'),
    _MockPage(icon: Icons.access_time_rounded, label: 'Historique'),
    _MockPage(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}

/// Page temporaire (mockup) adaptée au thème sombre / clair.
class _MockPage extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MockPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.zillaSlab(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Page en construction',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}