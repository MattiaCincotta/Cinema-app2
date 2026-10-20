import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

// Assume che Movie sia già importato tramite il provider

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'I Miei Preferiti',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Nessun film salvato',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (context, index) {
                  final movie = favorites[index];
                  // L'URL dell'immagine è la concatenazione esatta di https://image.tmdb.org/t/p/w500 e movie.posterPath
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                      // Mostra un contenitore grigio chiaro durante il caricamento
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        // Container grigio chiaro durante il caricamento
                        return Container(
                          color: const Color(0xFFE0E0E0),
                        );
                      },
                      // Mostra un contenitore grigio scuro con un'icona di errore al centro se il caricamento fallisce
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF424242),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.error,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}