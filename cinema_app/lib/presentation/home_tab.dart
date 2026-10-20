import 'dart:async';
import 'package:flutter/material.dart';
import '../data/tmdb_service.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart'; // Assicurati che questo sia il path giusto
import '../providers/watchlist_provider.dart'; // Richiesto per il controllo watchlist

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Future<List<List<Movie>>> _fetchAllMovies() {
    final tmdbService = TmdbService();
    // Ordine Popolari, Horror, Fantascienza, Azione, Commedia, Animazione
    return Future.wait([
      tmdbService.getPopularMovies(),
      tmdbService.getMoviesByGenre(27),
      tmdbService.getMoviesByGenre(878),
      tmdbService.getMoviesByGenre(28),
      tmdbService.getMoviesByGenre(35),
      tmdbService.getMoviesByGenre(16),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar eliminata come da istruzioni
      body: FutureBuilder<List<List<Movie>>>(
        future: _fetchAllMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nessun film trovato.'));
          }

          // Recupero le liste separate
          final List<Movie> popList = List.from(snapshot.data![0]);
          final List<Movie> horrorList = List.from(snapshot.data![1]);
          final List<Movie> scifiList = List.from(snapshot.data![2]);
          final List<Movie> actionList = List.from(snapshot.data![3]);
          final List<Movie> comedyList = List.from(snapshot.data![4]);
          final List<Movie> animList = List.from(snapshot.data![5]);

          // Estrazione e rimozione dei primi 5 film dai Popolari
          final List<Movie> heroCarouselMovies = [];
          final List<Movie> filteredPopList = List.from(popList);
          for (int i = 0; i < 5 && filteredPopList.isNotEmpty; i++) {
            heroCarouselMovies.add(filteredPopList.removeAt(0));
          }

          final Set<int> seenIds = {};
          seenIds.addAll(heroCarouselMovies.map((m) => m.id));
          seenIds.addAll(filteredPopList.map((m) => m.id));

          final List<Movie> filteredHorror = horrorList.where((m) => !seenIds.contains(m.id)).toList();
          seenIds.addAll(filteredHorror.map((m) => m.id));

          final List<Movie> filteredScifi = scifiList.where((m) => !seenIds.contains(m.id)).toList();
          seenIds.addAll(filteredScifi.map((m) => m.id));

          final List<Movie> filteredAction = actionList.where((m) => !seenIds.contains(m.id)).toList();
          seenIds.addAll(filteredAction.map((m) => m.id));

          final List<Movie> filteredComedy = comedyList.where((m) => !seenIds.contains(m.id)).toList();
          seenIds.addAll(filteredComedy.map((m) => m.id));

          final List<Movie> filteredAnim = animList.where((m) => !seenIds.contains(m.id)).toList();
          seenIds.addAll(filteredAnim.map((m) => m.id));

          return ListView(
            padding: EdgeInsets.zero,
            cacheExtent: 2500,
            children: [
              if (heroCarouselMovies.isNotEmpty)
                HeroCarousel(movies: heroCarouselMovies),
              MovieCategoryRow(title: 'Popolari', movies: filteredPopList),
              MovieCategoryRow(title: 'Horror', movies: filteredHorror),
              MovieCategoryRow(title: 'Fantascienza', movies: filteredScifi),
              MovieCategoryRow(title: 'Azione', movies: filteredAction),
              MovieCategoryRow(title: 'Commedia', movies: filteredComedy),
              MovieCategoryRow(title: 'Animazione', movies: filteredAnim),
            ],
          );
        },
      ),
    );
  }
}

class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;

  const HeroCarousel({Key? key, required this.movies}) : super(key: key);

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      final int nextPage = _currentPage + 1;
      if (!mounted) return;
      if (nextPage < widget.movies.length) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
        _currentPage = nextPage;
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
        _currentPage = 0;
      }
    });

    _pageController.addListener(() {
      final int newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        _currentPage = newPage;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Carosello hero, design full-bleed con gradienti e titolo bottone
    return SizedBox(
      height: 550,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          final movie = widget.movies[index];
          String? heroImagePath = (movie.backdropPath != null && movie.backdropPath!.isNotEmpty)
              ? movie.backdropPath
              : (movie.posterPath.isNotEmpty ? movie.posterPath : null);
          final String imageUrl = heroImagePath != null
              ? 'https://image.tmdb.org/t/p/w1280$heroImagePath'
              : '';
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => MovieDetailsDialog(movie: movie),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Immagine principale
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[900],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.error, color: Colors.white30, size: 90),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: Colors.white30, size: 90),
                      ),
                // Gradiente nero dal basso verso l'alto
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          0.8,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Titolo e bottone in basso a sinistra
                Positioned(
                  left: 24,
                  bottom: 38,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder: azione Guarda ora qui
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Guarda ora',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MovieCategoryRow extends StatefulWidget {
  final String title;
  final List<Movie> movies;

  const MovieCategoryRow({
    required this.title,
    required this.movies,
    super.key,
  });

  @override
  State<MovieCategoryRow> createState() => _MovieCategoryRowState();
}

class _MovieCategoryRowState extends State<MovieCategoryRow> {
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w342';
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
    // Calcola target offset in avanti di 450 pixel senza superare la fine
    final maxOffset = _scrollController.position.maxScrollExtent;
    final target = (_scrollController.offset + _scrollAmount).clamp(0.0, maxOffset);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  void _scrollLeft() {
    // Calcola target offset indietro di 450 pixel senza superare l'inizio
    final target = (_scrollController.offset - _scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se la lista è vuota, mostra solo la label e il messaggio
    final bool isEmpty = widget.movies.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: 330,
          child: isEmpty
              ? const Center(child: Text('Nessun film trovato.'))
              : Stack(
                  children: [
                    ListView.builder(
                      cacheExtent: 2500,
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          widget.movies.length > 12 ? 12 : widget.movies.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final movie = widget.movies[index];
                        // Padding di 8 pixel orizzontali attorno a HoverMovieCard, crea spazio fra le locandine
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: _thumbnailWidth,
                            child: HoverMovieCard(
                              movie: movie,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => MovieDetailsDialog(movie: movie),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    // Freccia destra, interattiva
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
                          child: const Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ),
                    ),
                    // Freccia sinistra, interattiva
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
                          child: const Icon(Icons.chevron_left, color: Colors.white),
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

class MovieDetailsDialog extends StatelessWidget {
  final Movie movie;

  const MovieDetailsDialog({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? backdropPath = (movie.backdropPath != null && movie.backdropPath!.isNotEmpty)
        ? movie.backdropPath
        : (movie.posterPath.isNotEmpty ? movie.posterPath : null);
    final String imageUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w780$backdropPath'
        : '';
    return Dialog(
      backgroundColor: Colors.grey[900],
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // max width per dialog
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // L'immagine ora è dentro ClipRRect con sole curve superiori tramite BorderRadius.vertical
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.white30),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Chiudi',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Voto medio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD600), size: 24),
                        const SizedBox(width: 6),
                        Text(
                          movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Trama
                    Text(
                      movie.overview ?? 'Nessuna trama disponibile.',
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.05,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 26),
                    // Azioni ridisegnata: due Expanded e SizedBox fra loro, stili aggiornati
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final isFavorite = context.watch<FavoritesProvider>().isFavorite(movie);
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.read<FavoritesProvider>().toggleFavorite(movie);
                                },
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isFavorite ? "Rimuovi dai Preferiti" : "Aggiungi ai Preferiti",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final isInWatchlist = context.watch<WatchlistProvider>().isInWatchlist(movie);
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.read<WatchlistProvider>().toggleWatchlist(movie);
                                },
                                icon: Icon(
                                  isInWatchlist ? Icons.bookmark_added : Icons.bookmark_add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isInWatchlist ? "Rimuovi" : "Watchlist",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFCCCCCC),
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HoverMovieCard - Card con effetto hover animato in scala per la locandina film
class HoverMovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  const HoverMovieCard({Key? key, required this.movie, required this.onTap}) : super(key: key);

  @override
  State<HoverMovieCard> createState() => _HoverMovieCardState();
}

class _HoverMovieCardState extends State<HoverMovieCard> {
  bool isHovered = false;

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w342';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Immagine poster a tutto spazio senza taglio bordi
                Image.network(
                  '$_imageBaseUrl${widget.movie.posterPath}',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[850],
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[850],
                      child: const Icon(Icons.error, size: 48, color: Colors.white30),
                    );
                  },
                ),
                // Overlay gradiente dal basso con dissolvenza solo su hover, senza icona
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}