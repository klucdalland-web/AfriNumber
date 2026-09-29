import 'package:get/get.dart';

import '../../features/connectivity/connectivity.dart';
import '../../features/country_search/country_search.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/history/history.dart';
import '../../features/profile/profile.dart';

/// Injecte les contrôleurs des onglets Connectivité, Historique et Profil.
///
/// À appeler depuis le binding du layout principal :
/// ```dart
/// class MainBinding extends Bindings {
///   @override
///   void dependencies() {
///     AccountTabsBinding().dependencies();
///     // ... dépendances Accueil / Recherche
///   }
/// }
/// ```
/// Tous les contrôleurs sont `lazyPut(fenix: true)` : créés à la première
/// lecture de l'onglet, recréés si supprimés.
class AccountTabsBinding extends Bindings {
  @override
  void dependencies() {
    DashboardBindings().dependencies();
    CountrySearchBinding().dependencies();
    ConnectivityBinding().dependencies();
    HistoryBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
