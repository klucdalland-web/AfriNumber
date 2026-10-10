# AfriNumber Backend

Le backend AfriNumber est une API Laravel qui alimente l’application mobile et le site web. Il gère l’authentification, les abonnements, les rôles, les notifications, les fichiers et les services d’intégration.

## Objectif

Centraliser les données et la logique métier du produit afin d’assurer :

- un accès sécurisé aux comptes ;
- la gestion des utilisateurs et des organisations ;
- les transactions de paiement et les plans d’abonnement ;
- des notifications push fiables ;
- un panel admin pour les opérations internes.

## Stack technique

- Laravel 13
- PHP 8.3
- Laravel Sanctum
- Filament
- Spatie Permission
- Firebase
- SQLite en local pour le développement
- MySQL ou PostgreSQL selon l’environnement de production

## Structure du projet

```text
afriserver/
├── app/                 # logique applicative, modèles, policies, services
├── bootstrap/           # initialisation Laravel
├── config/              # configuration de l’application
├── database/            # migrations, seeders, factories
├── public/              # fichiers publics
├── resources/           # vues et assets
├── routes/              # définition des routes API et web
├── tests/               # tests automatisés
├── .env.example         # variables de configuration exemple
├── artisan              # CLI Laravel
├── composer.json
├── phpunit.xml
├── vite.config.js
└── README.md
```

## Démarrage rapide

```bash
cd afriserver
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

Le backend est ensuite accessible sur :

```text
http://localhost:8000
```

## Variables d’environnement

Le fichier `.env` doit contenir au minimum :

- `APP_NAME`
- `APP_ENV`
- `APP_KEY`
- `APP_URL`
- configuration de base de données ;
- paramètres email ;
- configuration Firebase ;
- clés de services tiers.

## Authentification et autorisations

Le projet combine :

- système d’authentification Laravel ;
- gestion des rôles et autorisations via Spatie ;
- panel administration avec Filament ;
- logique spécifique selon le type d’utilisateur / organisation.

### Rôles courants

- `super_admin`
- `operateur`
- `gestionnaire`

## Notifications

Le backend prend en charge les notifications via Firebase Cloud Messaging. Cela permet d’envoyer des alertes, rappels et messages push à l’application mobile.

## Tests

```bash
php artisan test
```

## Sécurité

- ne jamais committer les fichiers `.env` réels ;
- centraliser les accès sensibles ;
- sécuriser les routes admin et les permissions ;
- vérifier les politiques de données avant chaque release.

## Déploiement

Le backend peut être déployé sur :

- Render ;
- Railway ;
- VPS Linux ;
- plateforme Laravel compatible ;
- environnement cloud avec base de données externe.

## Maintenance

Pour mettre à jour les permissions et les rôles :

```bash
php artisan db:seed --class=RolesAndPermissionsSeeder
```

## Contribution

Chaque évolution backend doit être accompagnée :

- d’un test si le flux est critique ;
- d’une mise à jour des permissions si l’accès change ;
- d’une documentation claire pour les autres développeurs.
