import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../data/tmdb_service.dart' show Movie;
import 'movie_details_dialog.dart';
import 'package:cinema_app/presentation/widgets/hover_movie_card.dart';

// Callback che accetta il numero di pagina e restituisce una Future di lista di Movie
typedef MovieFetcher = Future<List<Movie>> Function(int);

class CategoryPage extends StatefulWidget {
  final String title;
  final Future<List<Movie>> Function(int) fetchMovies;

  const CategoryPage({
    Key? key,
    required this.title,
    required this.fetchMovies,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoadingInitial = true;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(() {
      // Quando lo scroll supera la soglia dal fondo, tenta di caricare altri film. Nessuna parentesi consentita nei commenti
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500)
        _loadMore();
    });
  }

  Future<void> _loadInitial() async {
    try {
      final List<Movie> firstPage = await widget.fetchMovies(1);
      setState(() {
        _movies.clear();
        _movies.addAll(firstPage);
        _isLoadingInitial = false;
        _currentPage = 1;
      });
      // Dopo aver impostato _isLoadingInitial a false, controlla se serve caricare più film per riempire lo schermo vuoto. Nessuna parentesi consentita nei commenti
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent < 100)
          _loadMore();
      });
    } catch (e) {
      setState(() {
        _isLoadingInitial = false;
      });
      print('Errore iniziale nel caricamento dei film: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isFetchingMore) return;
    setState(() {
      _isFetchingMore = true;
    });
    try {
      _currentPage += 1;
      final List<Movie> moreMovies = await widget.fetchMovies(_currentPage);
      setState(() {
        _movies.addAll(moreMovies);
      });
    } catch (e) {
      print('Errore durante la paginazione: $e');
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Ionicons.chevronBack,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Usa crossAxisCount impostato a 6 per dimezzare le colonne ed evitare lag. Nessuna parentesi consentita nei commenti
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      final poster = movie.posterPath;
                      // Se poster è nullo o vuoto, mostra segnaposto testuale. Nessuna parentesi nei commenti
                      if (poster.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Nessun poster',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      // Altrimenti usa il componente HoverMovieCard con effetto hover attivo. Nessuna parentesi nei commenti
                      return HoverMovieCard(
                        movie: movie,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => MovieDetailsDialog(movie: movie),
                          );
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _isFetchingMore ? 1.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: _isFetchingMore
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Ionicons.chevronDownOutline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Scorri per caricare altri film',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}