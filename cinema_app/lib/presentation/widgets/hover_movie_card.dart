import 'package:flutter/material.dart';
import '../../data/tmdb_service.dart'; // Assicurati che il path sia corretto e Movie sia disponibile

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