# AfriNumber

AfriNumber est une solution digitale qui permet d’obtenir des numéros de téléphone internationaux, payables via Mobile Money, afin de faciliter l’accès à des services numériques, la vérification de comptes et la communication professionnelle depuis l’Afrique.

Le projet est structuré en plusieurs modules : une application mobile Flutter, un site vitrine Next.js, une API Laravel et un service de fichiers dédié.

## Vue d’ensemble

### Objectif

Simplifier l’accès aux numéros internationaux pour les utilisateurs africains, sans dépendre d’une carte bancaire internationale, en s’appuyant sur des canaux de paiement locaux comme MTN MoMo, Airtel Money, MVola, etc.

### Problème résolu

- difficulté d’obtenir un numéro international depuis certains pays africains ;
- blocage lié à l’absence de carte bancaire internationale ;
- besoin d’un accès simple à la vérification d’identité et aux services numériques ;
- besoin d’un parcours d’inscription et d’abonnement fluide sur mobile et web.

### Fonctionnalités principales

- inscription et authentification utilisateur ;
- recherche de pays et de numéros disponibles ;
- sélection d’un plan d’abonnement ;
- paiement via Mobile Money ;
- gestion du profil utilisateur ;
- KYC / vérification documentaire ;
- notifications push Firebase ;
- tableau de bord utilisateur ;
- site vitrine pour présenter le produit et expliquer le fonctionnement.

## Stack technique

| Composant | Technologie | Rôle |
|---|---|---|
| Application mobile | Flutter / Dart | Expérience utilisateur principale |
| Site web | Next.js / React / TypeScript | Présentation du produit |
| API backend | Laravel / PHP | Authentification, abonnements, données, intégrations |
| Base de données | SQLite en local, MySQL/Postgres selon l’environnement | Stockage applicatif |
| Notifications | Firebase Cloud Messaging | Push notifications |
| Fichiers / médias | Service dédié Node.js / Express | Upload et gestion de fichiers |

## Structure du dépôt

```text
AfriNumber/
├── afri_number/          # Application mobile Flutter
├── afri_web/             # Site vitrine Next.js
├── afriserver/           # API Laravel principale
├── afriserver_file/      # Service fichier / uploads
├── LICENSE
├── README.md             # Documentation globale
└── .gitignore
```

## Sous-projets

### 1) Application mobile - afri_number

C’est l’application principale en Flutter. Elle contient les modules suivants :

- welcome
- auth
- dashboard
- country_search
- abonnement
- profile
- kyc
- notifications
- messages
- connectivity
- history

Elle utilise :

- Flutter + Dart
- GetX pour la navigation / état
- Dio pour les appels réseau
- GetStorage pour le stockage local
- Firebase pour les notifications
- PhoneFormField pour les numéros de téléphone

#### Lancer l’application mobile

```bash
cd afri_number
flutter pub get
flutter run
```

### 2) Site vitrine - afri_web

Le site présente l’offre AfriNumber, les fonctionnalités, les tarifs et les informations légales.

#### Lancer le site web

```bash
cd afri_web
npm install
npm run dev
```

Le site est accessible ensuite sur :

```text
http://localhost:3000
```

### 3) Backend API - afriserver

Le backend est une API Laravel utilisée pour :

- gérer les utilisateurs ;
- gérer l’authentification ;
- gérer les abonnements ;
- gérer les opérations liées aux numéros ;
- envoyer des emails / notifications ;
- intégrer Firebase pour les notifications push.

#### Lancer l’API

```bash
cd afriserver
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

Le serveur démarre généralement sur :

```text
http://localhost:8000
```

> Le fichier `.env.example` contient les variables de configuration de base, notamment Firebase et les paramètres du mailer.

### 4) Service fichier - afriserver_file

Ce module est dédié aux fichiers et uploads, avec un service Node.js de gestion de contenu média et de ressources associées.

## Variables d’environnement

### Laravel / API

Le backend attend un fichier `.env` avec au minimum :

- `APP_NAME`
- `APP_ENV`
- `APP_KEY`
- `APP_URL`
- configuration de la base de données ;
- paramètres Firebase ;
- configuration des mails et notifications.

Exemple de base disponible dans :

```text
afriserver/.env.example
```

### Web Next.js

Le site peut nécessiter des variables publiques ou privées en fonction des intégrations (réseaux sociaux, API de contenu, configuration de runtime, etc.).

Créez un fichier `.env.local` si besoin, sans exposer les secrets côté navigateur.

## Parcours utilisateur typique

```text
Accueil / présentation
  → Inscription / connexion
  → Sélection du pays et du numéro souhaité
  → Choix du plan / abonnement
  → Paiement Mobile Money
  → Validation du compte / KYC
  → Accès au dashboard
  → Gestion des notifications et des profils
```

## Points forts du projet

- architecture multi-plateforme (mobile + web + API) ;
- usage de technologies modernes et adaptées au hackathon ;
- parcours utilisateur complet de l’inscription à l’abonnement ;
- intégration de services concrets : Firebase, paiement mobile, API Laravel ;
- code facilement extensible pour ajouter d’autres pays, plans ou intégrations.

## Déploiement

Le projet est prêt pour une logique de déploiement sur plusieurs environnements :

- mobile : Android / iOS / web Flutter ;
- web : Vercel ou hébergement Node compatible Next.js ;
- backend : Render, Railway, VPS ou hébergement Laravel ;
- stockage / fichiers : service dédié ou service cloud compatible S3.

## Bonnes pratiques de développement

- garder les fonctionnalités par module ;
- respecter la séparation entre application mobile, site web et backend ;
- documenter chaque nouvelle API ou intégration ;
- tester les flux de paiement et d’authentification avant mise en production ;
- sécuriser les variables d’environnement et les tokens.

## Licence

Ce projet est sous licence MIT. Consultez le fichier LICENSE pour plus de détails.

## Contributeurs

Le dépôt est conçu pour favoriser le développement collaboratif autour d’un produit orienté "numéro international + Mobile Money + Afrique".
