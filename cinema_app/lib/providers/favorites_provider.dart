import 'package:flutter/material.dart';
import '../data/tmdb_service.dart';

class FavoritesProvider extends ChangeNotifier {
  // Lista privata dei film preferiti
  final List<Movie> _favorites = [];

  // Getter pubblico per la lista dei preferiti
  List<Movie> get favorites => List.unmodifiable(_favorites);

  // Aggiunge o rimuove un film dai preferiti e notifica i listener
  void toggleFavorite(Movie movie) {
    final index = _favorites.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }

  // Controlla se un film è tra i preferiti
  bool isFavorite(Movie movie) {
    return _favorites.any((m) => m.id == movie.id);
  }
}