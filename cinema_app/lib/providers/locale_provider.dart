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