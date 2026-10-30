# AfriNumber Mobile

L’application mobile AfriNumber est le cœur de l’expérience utilisateur. Elle permet à un utilisateur d’inscrire son compte, choisir un numéro international, gérer un abonnement et accéder à son espace personnel depuis un téléphone.

## Objectif

Mettre à disposition une application mobile simple, fiable et accessible pour :

- créer un compte ;
- choisir un numéro de téléphone international ;
- payer via Mobile Money ;
- gérer la communication professionnelle ;
- recevoir des notifications et suivre son usage.

## Stack technique

- Flutter
- Dart
- GetX
- Dio
- GetStorage
- Firebase Core + Firebase Messaging
- PhoneFormField
- Material 3

## Architecture

```text
lib/
├── app/                  # routes, bindings, thème, configuration de démarrage
├── core/                 # services partagés, API, local storage, traductions
├── features/             # modules métier : auth, dashboard, profile, kyc, etc.
├── firebase_options.dart # configuration Firebase
├── main.dart             # point d’entrée de l’application
└── generated/            # fichiers générés selon le besoin de l’environnement
```

## Modules principaux

- welcome : écran d’introduction et acquisition utilisateur ;
- auth : inscription, connexion, OTP, mot de passe oublié ;
- dashboard : vue centrale après connexion ;
- country_search : recherche de pays et de numéros ;
- abonnement : gestion des plans et paiements ;
- profile : données utilisateur et compte ;
- kyc : vérification d’identité et pièces justificatives ;
- notifications : push notifications et messages ;
- history : historique des usages et transactions ;
- connectivity : gestion des services de connectivité ;
- messages : gestion de messages et communications.

## Démarrage rapide

```bash
cd afri_number
flutter pub get
flutter run
```

## Lancer en mode debug

```bash
flutter run --debug
```

## Build de production

### Android

```bash
flutter build apk
```

### iOS

```bash
flutter build ios
```

## Gestion de l’état et navigation

L’application s’appuie sur GetX pour :

- la navigation entre écrans ;
- l’injection de dépendances ;
- les contrôleurs d’écran ;
- la gestion de l’état local.

Le point d’entrée configure le thème, les traductions et les bindings de l’application.

## Configuration Firebase

Le projet initialise Firebase au démarrage dans [lib/main.dart](lib/main.dart). Les options de configuration sont définies dans [lib/firebase_options.dart](lib/firebase_options.dart).

## Bonnes pratiques du projet

- garder chaque feature dans son propre dossier ;
- séparer la logique UI, le métier et les données ;
- centraliser le chemin API dans les services dédiés ;
- éviter de dupliquer les composants UI ;
- documenter chaque nouveau flux métier.

## Déploiement

L’application est prête pour un déploiement sur :

- Android Play Store ;
- App Store iOS ;
- environnement de test interne ;
- build de QA avant mise en production.

## Contribution

Pour ajouter une nouvelle fonctionnalité, suivre la logique actuelle :

1. créer le module dans `lib/features/` ;
2. créer les vues et contrôleurs associés ;
3. brancher la route dans l’application ;
4. intégrer le service API ou le stockage local nécessaire ;
5. valider le flux complet côté interface.
