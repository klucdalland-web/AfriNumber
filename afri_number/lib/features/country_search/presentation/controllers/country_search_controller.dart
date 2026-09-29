import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/country_item.dart';

class CountrySearchController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<CountryItem> allCountries = <CountryItem>[].obs;
  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadCountries();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  void clearSearch() {
    searchInputController.clear();
    searchQuery.value = '';
  }

  List<CountryItem> get popularCountries =>
      allCountries.where((c) => c.isPopular).toList();

  List<CountryItem> get filteredCountries {
    final query = searchQuery.value;
    if (query.isEmpty) {
      return allCountries;
    }
    return allCountries.where((country) {
      final translatedName = 'country.${country.id.toUpperCase()}'.tr;
      final nameMatch =
          translatedName.toLowerCase().contains(query) ||
          country.name.toLowerCase().contains(query);
      final codeMatch = country.code.toLowerCase().contains(query);
      return nameMatch || codeMatch;
    }).toList();
  }

  void _loadCountries() {
    allCountries.assignAll(const [
      CountryItem(
        id: 'us',
        name: 'États-Unis',
        code: '+1',
        availableNumbers: 1240,
        isPopular: true,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'uk',
        name: 'Royaume-Uni',
        code: '+44',
        availableNumbers: 850,
        isPopular: true,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'fr',
        name: 'France',
        code: '+33',
        availableNumbers: 2100,
        isPopular: true,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'ca',
        name: 'Canada',
        code: '+1',
        availableNumbers: 1500,
        isPopular: true,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'de',
        name: 'Allemagne',
        code: '+49',
        availableNumbers: 920,
        isPopular: false,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'mg',
        name: 'Madagascar',
        code: '+261',
        availableNumbers: 430,
        isPopular: false,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'ci',
        name: 'Côte d\'Ivoire',
        code: '+225',
        availableNumbers: 670,
        isPopular: false,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'sn',
        name: 'Sénégal',
        code: '+221',
        availableNumbers: 510,
        isPopular: false,
        icon: Icons.public_rounded,
      ),
      CountryItem(
        id: 'cm',
        name: 'Cameroun',
        code: '+237',
        availableNumbers: 390,
        isPopular: false,
        icon: Icons.public_rounded,
      ),
    ]);
  }
}
