import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String searchQuery = '';
  List<dynamic> searchResults = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isFetchingMore = false;

  String? _selectedGenre;
  String? _selectedYear;
  double? _selectedRating;

  String? get selectedGenre => _selectedGenre;
  String? get selectedYear => _selectedYear;
  double? get selectedRating => _selectedRating;

  void setSelectedGenre(String? genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void setSelectedYear(String? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSelectedRating(double? rating) {
    _selectedRating = rating;
    notifyListeners();
  }

  // Metodo per ottenere la prossima pagina dei risultati della ricerca
  Future<void> fetchNextPage() async {
    if (!hasMore || isLoading || isFetchingMore) return;
    isFetchingMore = true;
    notifyListeners();

    try {
      currentPage += 1;
    } catch (e) {
      // Gestione errore caricamento pagina successiva
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  // Metodo per avviare una ricerca con la nuova query
  Future<void> search(String query) async {
    searchQuery = query;
    currentPage = 1;
    hasMore = true;
    searchResults = [];
    isLoading = true;
    notifyListeners();

    try {
    } catch (e) {
      // Gestione errore ricerca
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}