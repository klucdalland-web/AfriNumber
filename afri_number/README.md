# AfriNumber (mobile)

Application Flutter AfriNumber — architecture **feature-first** + **GetX**, avec une couche **core** partagée pour le réseau et l’UI.

## Démarrage

```bash
cd afri_number
flutter pub get
flutter run
```

## Architecture mobile

### 1. Démarrage

```
main.dart
  → GetStorage.init()
  → GetMaterialApp (thème, routes)
  → InitialBinding (services globaux)
```

Au lancement : storage, Dio et thème sont injectés une fois pour toute l’app.

### 2. Les 3 grandes zones

```
lib/
├── app/        → “colonne vertébrale” (routes, thème, DI)
├── core/       → outils partagés (API, widgets, storage)
└── features/   → écrans métier (welcome, auth, dashboard)
```

| Zone | Question qu’elle répond |
|------|-------------------------|
| **app/** | Comment l’app démarre et navigue ? |
| **core/** | Comment on parle au serveur / UI de base ? |
| **features/** | Quelles fonctionnalités métier ? |

### 3. Navigation (GetX)

```
AppRoutes   → noms des routes ("/", "/login"…)
AppPages    → quelle page pour quelle route
```

Flux actuel :

```
Accueil (/) → Connexion / Inscription → Dashboard
```

Navigation typique : `Get.toNamed(...)`, `Get.offAllNamed(...)`.

### 4. Feature Auth (modèle à suivre)

Auth est découpé en **3 couches** (Clean Architecture allégée) :

```
features/auth/
├── presentation/   → ce que l’utilisateur voit
│   ├── views/          LoginPage, RegisterPage
│   └── controllers/    AuthController (logique écran)
├── domain/         → règles métier (indépendant de Flutter/Dio)
│   └── repositories/   AuthRepository (contrat)
└── data/           → implémentation technique
    ├── datasources/    AuthRemoteDataSource (appels API)
    └── repositories/   AuthRepositoryImpl
```

**Flux d’un login (quand le formulaire sera branché) :**

```
LoginPage
  → AuthController.login()
    → AuthRepository.login()
      → AuthRemoteDataSource (Dio)
        → API backend
      ← token
    → StorageService.saveAccessToken()
  → navigation Dashboard
```

Chaque couche a un rôle clair : UI ≠ métier ≠ HTTP.

### 5. Core réseau

```
DioClient
  ├── AuthInterceptor   → ajoute Bearer token, gère 401
  ├── ErrorInterceptor  → transforme erreurs en ApiException
  └── PrettyDioLogger   → logs en debug
```

Tout appel API passe par `DioClient` → un seul endroit pour headers, token et erreurs.

Configurer l’URL de base dans `lib/core/constants/api_constants.dart`.

### 6. Core UI

```
AppScaffold     → Scaffold Material / Cupertino iOS
AppButton       → boutons adaptatifs
AppText         → typo unifiée
AppIconButton
```

Import unique :

```dart
import 'package:afri_number/core/widgets/widgets.dart';
```

Les pages n’utilisent pas `Scaffold` / `ElevatedButton` directement → UI cohérente.

### 7. Schéma global

```
┌─────────────────────────────────────────┐
│                 app/                    │
│   routes · theme · bindings             │
└─────────────────┬───────────────────────┘
                  │
     ┌────────────┼────────────┐
     ▼            ▼            ▼
 welcome       auth        dashboard
     │            │            │
     │     ┌──────┴──────┐     │
     │     │ presentation│     │
     │     │ domain      │     │
     │     │ data        │     │
     │     └──────┬──────┘     │
     │            │            │
     └────────────┼────────────┘
                  ▼
            ┌──────────┐
            │   core   │
            │ Dio · UI │
            │ storage  │
            └────┬─────┘
                 ▼
              API backend
```

### 8. Ajouter une feature

Exemple « profil » :

1. Créer `features/profile/presentation/views/profile_page.dart`
2. Déclarer la route dans `app_routes` + `app_pages`
3. Si besoin API : ajouter `data/` + `domain/` comme pour auth
4. Construire l’UI avec `AppScaffold` / `AppButton` / `AppText`

### En une phrase

**GetX pour la nav et l’état, features pour le métier, core pour l’API et les composants** — chaque fichier a une responsabilité unique.
