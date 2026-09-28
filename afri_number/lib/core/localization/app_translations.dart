import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service de traductions GetX (Français / Anglais).
class AppTranslations extends Translations {
  static const fallbackLocale = Locale('fr', 'FR');

  static final locales = [
    const Locale('fr', 'FR'),
    const Locale('en', 'US'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'fr_FR': {
          'welcome_title': 'Votre avenir n\'a plus de frontières, avec AfriNumber',
          'login_title': 'De Retour !',
          'login_subtitle': 'Heureux de vous revoir ! Connectez-vous pour continuer là où vous vous êtes arrêté.',
          'phone_label': 'Téléphone',
          'password_label': 'Mot de passe',
          'remember_me': 'Se souvenir de moi',
          'forgot_password': 'Mot de passe oublié',
          'login_button': 'Connexion',
          'no_account': 'Vous n\'avez pas encore de compte ?',
          'signup_free': 'S\'inscrire gratuitement.',
          'language': 'Langue',
          'french': 'Français',
          'english': 'English',
          'dashboard': 'Tableau de bord',
          'history': 'Historique',
          'connectivity': 'Connectivité',
          'profile': 'Profil',
          'search': 'Recherche',
        },
        'en_US': {
          'welcome_title': 'Your future has no boundaries, with AfriNumber',
          'login_title': 'Welcome Back!',
          'login_subtitle': 'Glad to see you again! Log in to continue where you left off.',
          'phone_label': 'Phone',
          'password_label': 'Password',
          'remember_me': 'Remember me',
          'forgot_password': 'Forgot password',
          'login_button': 'Login',
          'no_account': 'Don\'t have an account yet?',
          'signup_free': 'Sign up for free.',
          'language': 'Language',
          'french': 'Français',
          'english': 'English',
          'dashboard': 'Dashboard',
          'history': 'History',
          'connectivity': 'Connectivity',
          'profile': 'Profile',
          'search': 'Search',
        },
      };
}
