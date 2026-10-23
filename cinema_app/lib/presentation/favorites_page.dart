import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/locale_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icona indietro Ionicons.chevronBackOutline colore bianco opaco e dimensione 24
        leading: IconButton(
          icon: Icon(
            Ionicons.chevronBackOutline,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          localeProvider.translate('favorites'),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: favorites.isEmpty
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
                        Ionicons.heartOutline,
                        size: 48,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.watch<LocaleProvider>().translate('no_movies_in_favorites'),
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
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (context, index) {
                  final movie = favorites[index];
                  final posterPath = movie.posterPath;
                  // Gestisci poster null o vuoto in modo simile a SearchPage
                  if (posterPath == null || posterPath.isEmpty) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Text(
                            localeProvider.translate('no_poster'),
                            style: const TextStyle(
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  final imageUrl = posterPath.startsWith('/')
                      ? 'https://image.tmdb.org/t/p/w500$posterPath'
                      : 'https://image.tmdb.org/t/p/w500/$posterPath';

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      // Container grigio chiaro durante caricamento
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFE0E0E0),
                        );
                      },
                      // Container grigio scuro con icona errore se caricamento fallisce
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