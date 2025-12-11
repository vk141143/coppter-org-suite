class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Waste Management',
      'welcome_back': 'Welcome Back',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'dashboard': 'Dashboard',
      'profile': 'Profile',
      'logout': 'Logout',
      'raise_complaint': 'Raise Complaint',
      'track_pickup': 'Track Pickup',
      'my_complaints': 'My Complaints',
      'complaint_history': 'Complaint History',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
    },
    'es': {
      'app_name': 'Gestión de Residuos',
      'welcome_back': 'Bienvenido de nuevo',
      'sign_in': 'Iniciar sesión',
      'sign_up': 'Registrarse',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'dashboard': 'Panel',
      'profile': 'Perfil',
      'logout': 'Cerrar sesión',
      'raise_complaint': 'Presentar queja',
      'track_pickup': 'Rastrear recogida',
      'my_complaints': 'Mis quejas',
      'complaint_history': 'Historial de quejas',
      'settings': 'Configuración',
      'dark_mode': 'Modo oscuro',
      'language': 'Idioma',
      'notifications': 'Notificaciones',
    },
    'fr': {
      'app_name': 'Gestion des déchets',
      'welcome_back': 'Bon retour',
      'sign_in': 'Se connecter',
      'sign_up': 'S\'inscrire',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'forgot_password': 'Mot de passe oublié?',
      'dashboard': 'Tableau de bord',
      'profile': 'Profil',
      'logout': 'Se déconnecter',
      'raise_complaint': 'Déposer une plainte',
      'track_pickup': 'Suivre la collecte',
      'my_complaints': 'Mes plaintes',
      'complaint_history': 'Historique des plaintes',
      'settings': 'Paramètres',
      'dark_mode': 'Mode sombre',
      'language': 'Langue',
      'notifications': 'Notifications',
    },
  };

  static String currentLanguage = 'en';

  static String translate(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }

  static void setLanguage(String languageCode) {
    currentLanguage = languageCode;
  }
}