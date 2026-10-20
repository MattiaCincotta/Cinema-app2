import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>().watchlist;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'La mia Watchlist',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: watchlist.isEmpty
          ? const Center(
              child: Text(
                'Nessun film da guardare',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: watchlist.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (context, index) {
                  final movie = watchlist[index];
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
                          color: Color(0xFFE0E0E0),
                        );
                      },
                      // Mostra un contenitore grigio scuro con un'icona di errore al centro se il caricamento fallisce
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Color(0xFF424242),
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