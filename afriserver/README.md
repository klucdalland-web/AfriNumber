# AfriNumber (afriserver)

API Laravel + panel d’administration Filament (`/afriNetAdmin`).

## Accès panel vs permissions

Deux couches distinctes :

| Besoin | Mécanisme |
|--------|-----------|
| Entrer dans le dashboard | `TypeUser` avec `code = admin` |
| Agir dans le dashboard | Rôles / permissions Spatie |

Un compte `user` / `organisation` ne rentre jamais dans le panel, même avec un rôle Spatie.  
Un admin **sans** rôle Spatie entre au dashboard mais n’a accès à aucune resource.

Rôles seedés : `super_admin`, `operateur`, `gestionnaire`  
(`php artisan db:seed --class=RolesAndPermissionsSeeder`)

## Ajouter une nouvelle table / Resource Filament

Pour chaque nouvelle table gérée dans le panel, suivre ces étapes.

### 1. Permissions

Ajouter les constantes dans `app/Support/PanelPermission.php` :

```php
public const ARTICLES_VIEW = 'articles.view';
public const ARTICLES_CREATE = 'articles.create';
public const ARTICLES_UPDATE = 'articles.update';
public const ARTICLES_DELETE = 'articles.delete';
```

Les inclure dans `all()`, puis les rattacher aux bons rôles dans `database/seeders/RolesAndPermissionsSeeder.php`.

Re-seed :

```bash
php artisan db:seed --class=RolesAndPermissionsSeeder
```

### 2. Policy

```bash
php artisan make:policy ArticlePolicy --model=Article --no-interaction
```

```php
class ArticlePolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'articles'; // même préfixe que les permissions
    }
}
```

Laravel découvre automatiquement la policy si le modèle est `App\Models\Article`.

### 3. Resource Filament

```bash
php artisan make:filament-resource Article --generate --no-interaction
```

Rien de spécial à brancher pour l’auth : Filament appelle déjà la Policy (`viewAny`, `create`, `update`, `delete`).

### 4. Vérifier

- Un `super_admin` voit tout (via `Gate::before`)
- Un `operateur` / `gestionnaire` ne voit que ce que son rôle autorise
- Un admin sans rôle Spatie entre au dashboard mais n’ouvre pas la resource

## Assigner un rôle à un admin

Via le panel (**Administration → Administrateurs / Rôles**), ou en tinker :

```php
$user = \App\Models\User::where('email', '...')->first();
$user->assignRole('super_admin');
```
