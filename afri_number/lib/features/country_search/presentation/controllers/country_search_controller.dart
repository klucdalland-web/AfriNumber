import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/country_item.dart';
import '../../domain/repositories/country_repository.dart';

/// Contrôleur de la page Recherche de pays.
///
/// - Charge la liste via [CountryRepository.fetchCountries] (GET `/pays`).
/// - Filtre localement par nom ou indicatif selon [searchQuery].
/// - Expose [popularCountries] : les pays marqués `isPopular = true`.
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

  /// Met à jour la requête de recherche (en minuscule, sans espaces superflus).
  void updateSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  /// Réinitialise la barre de recherche.
  void clearSearch() {
    searchInputController.clear();
    searchQuery.value = '';
  }

  /// Retourne les pays mis en avant (pour la section "Pays populaires").
  /// Les pays de l'API n'ont pas ce champ ; on garde la compatibilité pour
  /// d'éventuels ajouts futurs côté mock ou backend.
  List<CountryItem> get popularCountries =>
      allCountries.take(5).toList();

  /// Retourne la liste filtrée selon [searchQuery].
  /// Recherche dans le nom ET dans l'indicatif téléphonique.
  List<CountryItem> get filteredCountries {
    final query = searchQuery.value;
    if (query.isEmpty) return allCountries;

    return allCountries.where((country) {
      return country.name.toLowerCase().contains(query) ||
          country.code.toLowerCase().contains(query) ||
          country.dialCode.contains(query);
    }).toList();
  }

  /// Charge tous les pays depuis l'API. Affiche un message d'erreur en cas d'échec.
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
