import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/tmdb_service.dart' ; // Assicurati che Movie sia disponibile
import '../movie_details_dialog.dart' ; // Import corretto per MovieDetailsDialog

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
    // Carosello hero, design full-bleed con gradienti e titolo
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
              : (movie.posterPath != null && movie.posterPath!.isNotEmpty ? movie.posterPath! : null);

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
                // Titolo in basso a sinistra
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
                      // Eliminato il bottone Guarda ora e lo SizedBox sottostante
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