import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Champ téléphone réutilisable (connexion / inscription) :
/// sélecteur limité aux pays de l'API, validation package, états chargement /
/// erreur / liste vide.
class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.auth,
    required this.phoneController,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
    this.hintKey = 'register.phone',
  });

  final AuthController auth;
  final PhoneController phoneController;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<PhoneNumber>? onSubmitted;
  final bool enabled;
  final String hintKey;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final hintColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final defaultBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Obx(() {
      if (auth.isLoadingCountries.value) {
        return _StatusBox(
          height: r.heightOf(50),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: r.space(12)),
              Expanded(
                child: Text(
                  'phone.countries_loading'.tr,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(14),
                    color: hintColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (auth.countriesLoadFailed.value) {
        return _StatusBox(
          height: r.heightOf(50),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'error.countries_load_failed'.tr,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(13),
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
              TextButton(
                onPressed: auth.loadCountries,
                child: Text('phone.retry'.tr),
              ),
            ],
          ),
        );
      }

      final allowed = auth.allowedIsoCodes;
      if (auth.countries.isEmpty || allowed.isEmpty) {
        return _StatusBox(
          height: r.heightOf(50),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  auth.countries.isEmpty
                      ? 'phone.countries_empty'.tr
                      : 'phone.countries_unsupported'.tr,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: r.fontSize(13),
                    color: hintColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: auth.loadCountries,
                child: Text('phone.retry'.tr),
              ),
            ],
          ),
        );
      }

      return PhoneFormField(
        key: ValueKey('phone-${allowed.map((e) => e.name).join('-')}'),
        controller: phoneController,
        focusNode: focusNode,
        enabled: enabled,
        textInputAction: textInputAction,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        countrySelectorNavigator: CountrySelectorNavigator.modalBottomSheet(
          countries: allowed,
          favorites: allowed.take(3).toList(),
          sortCountries: true,
          showDialCode: true,
          searchAutofocus: false,
          noResultMessage: 'phone.no_country_result'.tr,
        ),
        isCountrySelectionEnabled: true,
        isCountryButtonPersistent: true,
        countryButtonStyle: CountryButtonStyle(
          showDialCode: true,
          showFlag: true,
          showIsoCode: false,
          flagSize: r.space(18),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(14),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: GoogleFonts.ibmPlexSans(
          fontSize: r.fontSize(15),
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hintKey.tr.replaceAll('*', '').trim(),
          hintStyle: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(15),
            fontWeight: FontWeight.w400,
            color: hintColor,
          ),
          filled: true,
          fillColor: fieldBg,
          contentPadding: EdgeInsets.symmetric(
            vertical: r.space(14),
            horizontal: r.space(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.radius(28)),
            borderSide: BorderSide(color: defaultBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.radius(28)),
            borderSide: BorderSide(color: defaultBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.radius(28)),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.radius(28)),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.radius(28)),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          errorStyle: GoogleFonts.ibmPlexSans(
            fontSize: r.fontSize(12),
            color: const Color(0xFFEF4444),
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: PhoneValidator.compose([
          PhoneValidator.required(
            context,
            errorText: 'error.phone_required'.tr,
          ),
          PhoneValidator.valid(
            context,
            errorText: 'error.phone_invalid'.tr,
          ),
          PhoneValidator.validCountry(
            context,
            allowed,
            errorText: 'error.phone_country_invalid'.tr,
          ),
        ]),
        onChanged: auth.onPhoneChanged,
        onSubmitted: onSubmitted,
      );
    });
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(10)),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(r.radius(28)),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
