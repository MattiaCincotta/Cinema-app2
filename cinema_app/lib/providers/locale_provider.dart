import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  String _languageCode = 'it-IT';

  // Mappa statica delle traduzioni per le chiavi principali, evitare caratteri di parentesi nei commenti testuali
  static const Map<String, Map<String, String>> _translations = {
    'popular': {
      'it-IT': 'Popolari',
      'en-US': 'Popular',
      'es-ES': 'Populares',
    },
    'horror': {
      'it-IT': 'Horror',
      'en-US': 'Horror',
      'es-ES': 'Terror',
    },
    'action': {
      'it-IT': 'Azione',
      'en-US': 'Action',
      'es-ES': 'Acción',
    },
    'comedy': {
      'it-IT': 'Commedia',
      'en-US': 'Comedy',
      'es-ES': 'Comedia',
    },
    'trailer': {
      'it-IT': 'Trailer',
      'en-US': 'Trailer',
      'es-ES': 'Tráiler',
    },
    'favorites': {
      'it-IT': 'Preferiti',
      'en-US': 'Favorites',
      'es-ES': 'Favoritos',
    },
    'add_to_favorites': {
      'it-IT': 'Aggiungi ai Preferiti',
      'en-US': 'Add to Favorites',
      'es-ES': 'Añadir a Favoritos',
    },
    'directed_by': {
      'it-IT': 'Regia di',
      'en-US': 'Directed by',
      'es-ES': 'Dirigida por',
    },
    'search': {
      'it-IT': 'Cerca',
      'en-US': 'Search',
      'es-ES': 'Buscar',
    },
    'watchlist': {
      'it-IT': 'Watchlist',
      'en-US': 'Watchlist',
      'es-ES': 'Mi Lista',
    },
    'no_movies_in_favorites': {
      'it-IT': 'Nessun film nei preferiti',
      'en-US': 'No movies in favorites',
      'es-ES': 'No hay películas en favoritos',
    },
    'no_movies_in_watchlist': {
      'it-IT': 'Nessun film nella watchlist',
      'en-US': 'No movies in watchlist',
      'es-ES': 'No hay películas en la watchlist',
    },
    'change_language': {
      'it-IT': 'Cambia lingua',
      'en-US': 'Change language',
      'es-ES': 'Cambiar idioma',
    },
    'language': {
      'it-IT': 'Cambia lingua',
      'en-US': 'Change language',
      'es-ES': 'Cambiar idioma',
    },
    'scroll_to_load_more': {
      'it-IT': 'Scorri per caricare altri film',
      'en-US': 'Scroll to load more movies',
      'es-ES': 'Desliza para cargar más películas',
    },
    'see_all': {
      'it-IT': 'Vedi tutti',
      'en-US': 'See all',
      'es-ES': 'Ver todo',
    },
    'logout': {
      'it-IT': 'Esci',
      'en-US': 'Logout',
      'es-ES': 'Cerrar sesión',
    },
    'confirm_logout': {
      'it-IT': 'Sei sicuro di voler uscire?',
      'en-US': 'Are you sure you want to log out?',
      'es-ES': '¿Estás seguro de que deseas cerrar sesión?',
    },
    'cancel': {
      'it-IT': 'Annulla',
      'en-US': 'Cancel',
      'es-ES': 'Cancelar',
    },
    'confirm': {
      'it-IT': 'Conferma',
      'en-US': 'Confirm',
      'es-ES': 'Confirmar',
    },
    'not_available_short': {
      'it-IT': 'Non disponibile',
      'en-US': 'Not available',
      'es-ES': 'No disponible',
    },
    // Altre chiavi possono essere aggiunte qui seguendo lo stesso schema
  };

  String get languageCode => _languageCode;

  void changeLanguage(String newLanguageCode) {
    _languageCode = newLanguageCode;
    notifyListeners();
  }

  // Restituisce la traduzione per la chiave specificata oppure la chiave stessa se non presente, evitare caratteri di parentesi nei commenti testuali
  String translate(String key) {
    if (_translations.containsKey(key)) {
      final translationsForKey = _translations[key];
      if (translationsForKey != null && translationsForKey.containsKey(_languageCode)) {
        return translationsForKey[_languageCode]!;
      }
    }
    return key;
  }
}