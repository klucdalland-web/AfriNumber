import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/models/connectivity_service.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service});

  final ConnectivityService service;

  IconData get _icon => switch (service.type) {
        ConnectivityServiceType.esim => Icons.sim_card_outlined,
        ConnectivityServiceType.callForwarding => Icons.call_outlined,
        ConnectivityServiceType.smsNotification => Icons.alternate_email_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    final status = service.isActive ? 'Actif' : 'Inactif';
    final pillBg = service.isActive
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1E7DD))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final pillText = service.isActive
        ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF0F5132))
        : subtextColor;

    return Container(
      padding: EdgeInsets.all(r.space(14)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: r.widthOf(38),
            height: r.heightOf(38),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _icon,
                size: r.iconSize(20),
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: r.space(2)),
                Text(
                  service.isActive ? 'Service opérationnel' : 'Service désactivé',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(12),
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.space(10),
              vertical: r.space(4),
            ),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(r.radius(12)),
            ),
            child: Text(
              status,
              style: GoogleFonts.ibmPlexSans(
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w700,
                color: pillText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
