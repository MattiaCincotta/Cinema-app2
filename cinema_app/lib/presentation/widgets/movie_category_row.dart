import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' // Necessario per CupertinoIcons
    ;
import '../../data/tmdb_service.dart' // Per Movie
    ;
import '../widgets/hover_movie_card.dart' // Widget personalizzato delle locandine
    ;
import '../movie_details_dialog.dart' // Usa l'import corretto per MovieDetailsDialog
    ;
import '../category_page.dart' // Import necessario per CategoryPage
    ;

class MovieCategoryRow extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final VoidCallback? onSeeAll;
  final VoidCallback? onShowAll;

  const MovieCategoryRow({
    required this.title,
    required this.movies,
    this.onSeeAll,
    this.onShowAll,
    Key? key,
  }) : super(key: key);

  @override
  State<MovieCategoryRow> createState() => _MovieCategoryRowState();
}

class _MovieCategoryRowState extends State<MovieCategoryRow> {
  static const double _thumbnailWidth = 220;
  static const double _scrollAmount = 450;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final target =
        (_scrollController.offset + _scrollAmount).clamp(0.0, maxOffset);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset - _scrollAmount)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  // Determina il fetcher adatto in base al titolo della categoria
  Future<List<Movie>> Function(int) _resolveFetcher() {
    final tmdb = TmdbService();
    final lower = widget.title.toLowerCase();
    if (lower.contains('popolari')) {
      // Film popolari
      return (page) => tmdb.getPopularMovies(page: page);
    } else if (lower.contains('cinema') ||
        lower.contains('in sala') ||
        lower.contains('uscite')) {
      // Nuove uscite nei cinema
      return (page) => tmdb.getNowPlayingMovies(page: page);
    } else if (lower.contains('top rated') || lower.contains('votati')) {
      // Film più votati
      return (page) => tmdb.getTopRatedMovies(page: page);
    } else if (lower.contains('prossimi') ||
        lower.contains('presto') ||
        lower.contains('arrivo')) {
      // Prossime uscite
      return (page) => tmdb.getUpcomingMovies(page: page);
    }
    // Default fallback popolari
    return (page) => tmdb.getPopularMovies(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.movies.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Accento rosso verticale
              Container(
                width: 4,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2B37), // rosso acceso
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
              const SizedBox(width: 12),
              // Titolo categoria
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Area cliccabile Vedi tutti con icona
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onShowAll ??
                      widget.onSeeAll ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPage(
                              title: widget.title,
                              fetchMovies: _resolveFetcher(),
                            ),
                          ),
                        );
                      },
                  child: Row(
                    children: const [
                      Text(
                        'Vedi tutti',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC), // grigio chiaro
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Color(0xFFCCCCCC), // grigio chiaro
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 330,
          child: isEmpty
              ? const Center(
                  child: Text('Nessun film trovato.',
                      style: TextStyle(color: Colors.white)))
              : Stack(
                  children: [
                    ListView.builder(
                      cacheExtent: 2500,
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.movies.length > 12
                          ? 12
                          : widget.movies.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final movie = widget.movies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: _thumbnailWidth,
                            child: HoverMovieCard(
                              movie: movie,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      MovieDetailsDialog(movie: movie),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    // Freccia destra
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollRight();
                          }
                        },
                        child: Container(
                          width: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.chevron_right,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    // Freccia sinistra
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollLeft();
                          }
                        },
                        child: Container(
                          width: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.chevron_left,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}