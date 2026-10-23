import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../providers/locale_provider.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>().watchlist;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icona indietro Ionicons.chevronBackOutline colore bianco opacità 0.9 dimensione 24
        leading: IconButton(
          icon: Icon(
            Ionicons.chevronBackOutline,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          localeProvider.translate('watchlist'),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: watchlist.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: Colors.white12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Ionicons.bookmarkOutline,
                        size: 48,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.watch<LocaleProvider>().translate('no_movies_in_watchlist'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
                  // URL dell'immagine è la concatenazione esatta di https://image.tmdb.org/t/p/w500 con movie.posterPath
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                      // Mostra contenitore grigio chiaro durante il caricamento
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        // Container grigio chiaro durante il caricamento
                        return Container(
                          color: Color(0xFFE0E0E0),
                        );
                      },
                      // Mostra contenitore grigio scuro con icona errore al centro se il caricamento fallisce
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