import 'package:flutter/material.dart';
import '../data/tmdb_service.dart';

class WatchlistProvider extends ChangeNotifier {
  // Lista privata dei film nella watchlist
  final List<Movie> _watchlist = [];

  // Getter pubblico per la watchlist
  List<Movie> get watchlist => List.unmodifiable(_watchlist);

  // Aggiunge o rimuove un film dalla watchlist e notifica i listener
  void toggleWatchlist(Movie movie) {
    final index = _watchlist.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _watchlist.removeAt(index);
    } else {
      _watchlist.add(movie);
    }
    notifyListeners();
  }

  // Controlla se un film è presente nella watchlist
  bool isInWatchlist(Movie movie) {
    return _watchlist.any((m) => m.id == movie.id);
  }
}