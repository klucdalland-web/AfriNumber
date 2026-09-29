import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/country_constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Formulaire d'inscription complet (titre, champs, mentions légales,
/// bouton de soumission et lien de connexion).
class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'register.title'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: r.space(12)),
          Text(
            'register.subtitle'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
          _ErrorBanner(controller: controller),
          SizedBox(height: r.space(28)),
          CustomTextField(
            hintText: 'register.last_name'.tr,
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            controller: controller.lastNameController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'error.name_required'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: r.space(16)),
          CustomTextField(
            hintText: 'register.first_name'.tr,
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            controller: controller.firstNameController,
          ),
          SizedBox(height: r.space(16)),
          CustomTextField(
            hintText: 'register.email'.tr,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            controller: controller.emailController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'error.email_required'.tr;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'error.email_invalid'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: r.space(16)),

          // Champ téléphone avec sélecteur de pays / indicatif (+261, +33, etc.)
          _PhoneWithCountryPicker(controller: controller),

          SizedBox(height: r.space(16)),
          CustomTextField(
            hintText: 'register.password'.tr,
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.registerPasswordController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'error.password_required'.tr;
              }
              if (value.length < 8) {
                return 'error.register_password_too_short'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: r.space(16)),
          CustomTextField(
            hintText: 'register.confirm_password'.tr,
            icon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            controller: controller.confirmPasswordController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'error.confirm_required'.tr;
              }
              if (value != controller.registerPasswordController.text) {
                return 'error.password_mismatch'.tr;
              }
              return null;
            },
            onSubmitted: (_) => controller.register(),
          ),
          SizedBox(height: r.space(24)),
          AppButton.text(
            label: 'register.already_registered'.tr,
            onPressed: () => Get.toNamed(AppRoutes.login),
            foregroundColor: theme.colorScheme.onSurface,
            underline: true,
          ),
          SizedBox(height: r.space(16)),
          Obx(
            () => AppButton.primary(
              label: 'register.submit'.tr,
              isLoading: controller.isLoading.value,
              onPressed: controller.register,
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              radius: r.radius(28),
              height: r.heightOf(52),
            ),
          ),
          SizedBox(height: r.space(24)),
          _LegalText(),
        ],
      ),
    );
  }
}

class _PhoneWithCountryPicker extends StatelessWidget {
  const _PhoneWithCountryPicker({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown pour sélectionner le pays / indicatif
        Obx(
          () => Container(
            height: r.heightOf(50),
            padding: EdgeInsets.symmetric(horizontal: r.space(12)),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(r.radius(28)),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CountryData>(
                value: controller.selectedCountry.value,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(r.radius(16)),
                onChanged: (country) {
                  if (country != null) {
                    controller.selectedCountry.value = country;
                  }
                },
                items: kCountries.map((country) {
                  return DropdownMenuItem<CountryData>(
                    value: country,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlagBadge(code: country.code, size: 20),
                        SizedBox(width: r.space(6)),
                        Text(
                          '${country.code} ${country.dialCode}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: r.fontSize(13),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: r.space(10)),

        // Champ du numéro de téléphone
        Expanded(
          child: CustomTextField(
            hintText: 'register.phone'.tr,
            icon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            controller: controller.registerPhoneController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'error.phone_required'.tr;
              }
              final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
              if (digitsOnly.length < 6) {
                return 'Numéro invalide';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Obx(
      () => controller.errorMessage.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(top: r.space(16)),
              padding: EdgeInsets.all(r.space(12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(r.radius(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: r.iconSize(20),
                  ),
                  SizedBox(width: r.space(8)),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: r.fontSize(14),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return Text(
      'register.legal'.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: r.fontSize(12),
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        height: 1.5,
      ),
    );
  }
}
