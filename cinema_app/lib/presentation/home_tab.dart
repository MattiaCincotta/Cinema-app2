import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/tmdb_service.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/movie_category_row.dart';
import 'category_page.dart';
import 'package:cinema_app/providers/locale_provider.dart';

// Aggiunta della proprietà languageCode obbligatoria nella classe HomeTab, vietato usare caratteri di parentesi nei commenti testuali
class HomeTab extends StatefulWidget {
  final String languageCode;

  const HomeTab({super.key, required this.languageCode});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TmdbService tmdbService = TmdbService();

  List<Movie> popList = [];
  List<Movie> horrorList = [];
  List<Movie> scifiList = [];
  List<Movie> actionList = [];
  List<Movie> comedyList = [];
  List<Movie> animList = [];

  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Richiama fetchMovies principali e in parallelo Azione e Commedia senza caratteri di parentesi nei commenti testuali
    _fetchAndSetMovies();
    _fetchActionAndComedyMovies();
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Controllo cambio languageCode forza il ricaricamento dei dati senza caratteri di parentesi nei commenti testuali
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() {
        isLoading = true;
      });
      _fetchAndSetMovies();
      _fetchActionAndComedyMovies();
    }
  }

  Future<void> _fetchAndSetMovies() async {
    try {
      // Chiamata asincrona per popolari horror fantascienza e animazione senza caratteri di parentesi nei commenti testuali
      final results = await Future.wait([
        tmdbService.getPopularMovies(page: 1, language: widget.languageCode),
        tmdbService.getHorrorMovies(page: 1, language: widget.languageCode),
        tmdbService.getMoviesByGenre(878, page: 1, language: widget.languageCode),
        tmdbService.getMoviesByGenre(16, page: 1, language: widget.languageCode),
      ]);
      setState(() {
        popList = List.from(results[0]);
        horrorList = List.from(results[1]);
        scifiList = List.from(results[2]);
        animList = List.from(results[3]);
        isLoading = false;
        hasError = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchActionAndComedyMovies() async {
    try {
      // Esegue richieste Azione e Commedia aggiorna stato e stampa info senza caratteri di parentesi nei commenti testuali
      final action = await tmdbService.getActionMovies(page: 1, language: widget.languageCode);
      final comedy = await tmdbService.getComedyMovies(page: 1, language: widget.languageCode);
      setState(() {
        actionList = List.from(action);
        comedyList = List.from(comedy);
      });
      print('Lunghezza lista Azione: ${actionList.length}');
      print('Lunghezza lista Commedia: ${comedyList.length}');
    } catch (e) {
      // Ignora errori gestione errori viene fatta altrove senza caratteri di parentesi nei commenti testuali
      print('Errore fetching Azione o Commedia $e');
    }
  }

  void _openCategory({
    required String title,
    required Future<List<Movie>> Function(int) fetchMovies,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryPage(
          title: title,
          fetchMovies: fetchMovies,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final popularStr = localeProvider.translate('popular');
    final horrorStr = localeProvider.translate('horror');
    final actionStr = localeProvider.translate('action');
    final comedyStr = localeProvider.translate('comedy');
    final animationStr = localeProvider.translate('animation');
    final scifiStr = localeProvider.translate('scifi');

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage ?? 'Errore sconosciuto',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Gestione carousel eroi e lista Popolari senza caratteri di parentesi nei commenti testuali
    final List<Movie> heroCarouselMovies = [];
    final List<Movie> filteredPopList = List.from(popList);
    for (int i = 0; i < 5 && filteredPopList.isNotEmpty; i++) {
      heroCarouselMovies.add(filteredPopList.removeAt(0));
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        cacheExtent: 2500,
        children: [
          if (heroCarouselMovies.isNotEmpty)
            HeroCarousel(movies: heroCarouselMovies),
          MovieCategoryRow(
            title: popularStr,
            movies: popList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getPopularMovies con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: popularStr,
                fetchMovies: (page) => tmdbService.getPopularMovies(page: page, language: widget.languageCode),
              );
            },
          ),
          MovieCategoryRow(
            title: horrorStr,
            movies: horrorList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getHorrorMovies con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: horrorStr,
                fetchMovies: (page) => tmdbService.getHorrorMovies(page: page, language: widget.languageCode),
              );
            },
          ),
          MovieCategoryRow(
            title: scifiStr,
            movies: scifiList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getMoviesByGenre 878 con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: scifiStr,
                fetchMovies: (page) => tmdbService.getMoviesByGenre(878, page: page, language: widget.languageCode),
              );
            },
          ),
          MovieCategoryRow(
            title: actionStr,
            movies: actionList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getActionMovies con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: actionStr,
                fetchMovies: (page) => tmdbService.getActionMovies(page: page, language: widget.languageCode),
              );
            },
          ),
          MovieCategoryRow(
            title: comedyStr,
            movies: comedyList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getComedyMovies con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: comedyStr,
                fetchMovies: (page) => tmdbService.getComedyMovies(page: page, language: widget.languageCode),
              );
            },
          ),
          MovieCategoryRow(
            title: animationStr,
            movies: animList,
            onShowAll: () {
              // Passa fetchMovies che chiama tmdbService.getMoviesByGenre 16 con page e language senza caratteri di parentesi nei commenti testuali
              _openCategory(
                title: animationStr,
                fetchMovies: (page) => tmdbService.getMoviesByGenre(16, page: page, language: widget.languageCode),
              );
            },
          ),
        ],
      ),
    );
  }
}