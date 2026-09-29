import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/country_search_controller.dart';
import '../widgets/widgets.dart';

class CountrySearchPage extends StatelessWidget {
  const CountrySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CountrySearchController>();
    final r = context.responsive;
    final theme = Theme.of(context);
    final subtextColor = theme.colorScheme.onSurfaceVariant;

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.space(20),
            vertical: r.space(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP SEARCH BAR
              Obx(
                () => SearchBarInput(
                  scale: r.scale,
                  controller: controller.searchInputController,
                  searchQuery: controller.searchQuery.value,
                  onChanged: controller.updateSearchQuery,
                  onClear: controller.clearSearch,
                ),
              ),

              SizedBox(height: r.space(20)),

              // 2. MAIN SCROLLABLE BODY
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular countries section (only shown when search is empty)
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PopularCountriesSection(
                              scale: r.scale,
                              countries: controller.popularCountries,
                              onCountryTap: (country) {
                                Get.snackbar(
                                  'country.selected'.tr,
                                  '${'country.${country.id.toUpperCase()}'.tr} (${country.code})',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                            SizedBox(height: r.space(24)),
                          ],
                        );
                      }),

                      // Tous les pays Section Title
                      Text(
                        'country.all'.tr,
                        style: GoogleFonts.zillaSlab(
                          fontSize: r.fontSize(20 * r.scale),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      SizedBox(height: r.space(12)),

                      // Filtered Country List
                      Obx(() {
                        final countries = controller.filteredCountries;
                        if (countries.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(r.space(32)),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: r.iconSize(48),
                                    color: subtextColor,
                                  ),
                                  SizedBox(height: r.space(12)),
                                  Text(
                                    'country.empty'.tr,
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: r.fontSize(16),
                                      fontWeight: FontWeight.w600,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: countries.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: r.space(10 * r.scale)),
                          itemBuilder: (context, index) {
                            final country = countries[index];
                            return CountryListTile(
                              scale: r.scale,
                              country: country,
                              onTap: () {
                                Get.snackbar(
                                  'country.selected'.tr,
                                  '${'country.${country.id.toUpperCase()}'.tr} (${country.code})',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            );
                          },
                        );
                      }),

                      SizedBox(height: r.space(20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
