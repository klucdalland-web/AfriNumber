import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/country_item.dart';
import '../../domain/repositories/country_repository.dart';

class CountrySearchController extends GetxController {
  CountrySearchController(this._repository);

  final CountryRepository _repository;
  final searchQuery = ''.obs;
  final allCountries = <CountryItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCountries();
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
      allCountries.where((country) => country.isPopular).toList();

  List<CountryItem> get filteredCountries {
    final query = searchQuery.value;
    if (query.isEmpty) return allCountries;

    return allCountries.where((country) {
      final translatedName = 'country.${country.id.toUpperCase()}'.tr;
      return translatedName.toLowerCase().contains(query) ||
          country.name.toLowerCase().contains(query) ||
          country.code.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadCountries() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      allCountries.assignAll(await _repository.fetchCountries());
    } catch (_) {
      errorMessage.value = 'country.load_error'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
