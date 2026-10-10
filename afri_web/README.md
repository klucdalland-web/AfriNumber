# AfriNumber Web

Le site web AfriNumber sert de vitrine commerciale et de point d’entrée pour présenter la solution, expliquer le concept et orienter les visiteurs vers l’inscription, l’achat d’un numéro international ou la découverte des offres.

## Objectif

Présenter le produit de manière claire et convaincante pour un public africain, avec une communication orientée :

- simplicité ;
- paiement mobile ;
- numéros internationaux ;
- accès rapide au service ;
- confiance et professionnalisme.

## Stack

- Next.js 16
- React 19
- TypeScript
- Tailwind CSS
- Zustand pour l’état local
- composants UI customisés avec shadcn / Base UI

## Structure du projet

```text
afri_web/
├── app/                 # pages et layout Next.js
├── components/          # composants UI réutilisables
├── config/              # configuration globale
├── features/            # modules métier du front
├── lib/                 # utilitaires, helpers, intégrations
├── public/              # assets statiques
├── store/               # stores Zustand
├── package.json
├── next.config.ts
├── tsconfig.json
└── README.md
```

## Lancer le projet

### Installation

```bash
cd afri_web
npm install
```

### Mode développement

```bash
npm run dev
```

Puis ouvrir :

```text
http://localhost:3000
```

### Build de production

```bash
npm run build
npm run start
```

## Variables d’environnement

Le projet peut dépendre de variables de configuration selon les intégrations utilisées. En pratique :

- créer un fichier `.env.local` si nécessaire ;
- ne jamais exposer les secrets dans le navigateur ;
- conserver les valeurs sensibles côté serveur uniquement.

## Fonctionnalités du site

- page d’accueil avec proposition de valeur ;
- sections de présentation des avantages ;
- FAQ et informations pratiques ;
- pages produit / à propos / mentions légales ;
- formulaire de contact ;
- navigation claire pour orienter vers l’achat et l’inscription.

## Points forts

- interface moderne et orientée conversion ;
- contenu adapté à un contexte africain et mobile-first ;
- architecture simple et maintenable ;
- compatible avec la stratégie de produit globale AfriNumber.

## Déploiement

Le site peut être déployé sur :

- Vercel ;
- un hébergement Node.js standard ;
- une plateforme compatible Next.js avec build statique ou SSR.

## Contribution

Les modifications doivent rester cohérentes avec l’identité visuelle et la proposition de valeur AfriNumber : simplicité, confiance et accessibilité mobile.
