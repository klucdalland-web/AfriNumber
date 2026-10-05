import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';
import 'platform_utils.dart';

/// Service de pop-up / dialogues adaptatifs (iOS / Android) haut de gamme.
class AppDialog {
  AppDialog._();

  /// Affiche une boîte de dialogue d'erreur adaptative selon la plateforme.
  /// Se ferme automatiquement après [autoDismissDuration] (par défaut 5 secondes).
  static Future<void> showError({
    BuildContext? context,
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onConfirm,
    Duration autoDismissDuration = const Duration(seconds: 5),
  }) async {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    // Retours haptiques
    HapticFeedback.mediumImpact();

    final dialogTitle = title ?? 'Erreur';
    final confirmText = buttonText ?? 'Compris';

    Timer? dismissTimer;

    void dismissDialog(BuildContext dialogCtx) {
      dismissTimer?.cancel();
      if (Navigator.of(dialogCtx).canPop()) {
        Navigator.of(dialogCtx).pop();
      }
      if (onConfirm != null) onConfirm();
    }

    if (isApplePlatform) {
      showCupertinoDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (dialogCtx) {
          dismissTimer = Timer(autoDismissDuration, () {
            dismissDialog(dialogCtx);
          });

          return CupertinoAlertDialog(
            title: Text(
              dialogTitle,
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                message,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => dismissDialog(dialogCtx),
                child: Text(
                  confirmText,
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Android / Material 3 Dialog
      showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (dialogCtx) {
          dismissTimer = Timer(autoDismissDuration, () {
            dismissDialog(dialogCtx);
          });

          final theme = Theme.of(dialogCtx);
          final isDark = theme.brightness == Brightness.dark;
          final r = dialogCtx.responsive;

          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.radius(28)),
            ),
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.all(r.space(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête : Icône d'erreur rouge dans une pastille circulaire
                  Container(
                    width: r.iconSize(56),
                    height: r.iconSize(56),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: r.iconSize(32),
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  SizedBox(height: r.space(16)),

                  // Titre
                  Text(
                    dialogTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(18),
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: r.space(8)),

                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(14),
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: r.space(24)),

                  // Bouton d'action pilule
                  SizedBox(
                    width: double.infinity,
                    height: r.heightOf(48),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.radius(24)),
                        ),
                      ),
                      onPressed: () => dismissDialog(dialogCtx),
                      child: Text(
                        confirmText,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: r.fontSize(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
