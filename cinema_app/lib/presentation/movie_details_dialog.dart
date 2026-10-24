import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/tmdb_service.dart' show Movie, TmdbService;
import '../providers/favorites_provider.dart';
import '../providers/watchlist_provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cinema_app/presentation/widgets/youtube_video_player.dart';
import 'package:cinema_app/providers/locale_provider.dart';

class MovieDetailsDialog extends StatefulWidget {
  final Movie movie;

  const MovieDetailsDialog({super.key, required this.movie});

  @override
  State<MovieDetailsDialog> createState() => _MovieDetailsDialogState();
}

class _MovieDetailsDialogState extends State<MovieDetailsDialog> {
  String? _director;
  bool _loadingDirector = true;
  // Variabili stato per la visualizzazione trailer senza parentesi nei commenti testuali
  bool _showTrailer = false;
  String? _trailerId;

  @override
  void initState() {
    super.initState();
    _fetchDirector();
  }

  Future<void> _fetchDirector() async {
    try {
      final tmdbService = TmdbService();
      final details = await tmdbService.fetchMovieDetails(widget.movie.id);
      String foundDirector = '';
      final credits = details?['credits'];
      final crew = credits != null ? credits['crew'] as List<dynamic>? : null;
      if (crew != null) {
        final directors = crew.where((c) => c['job'] == 'Director');
        if (directors.isNotEmpty) {
          final firstDirector = directors.first;
          foundDirector = firstDirector['name'] ?? '';
        }
      }
      setState(() {
        _director = foundDirector;
        _loadingDirector = false;
      });
    } catch (e) {
      setState(() {
        _director = '';
        _loadingDirector = false;
      });
    }
  }

  Future<void> _launchTrailer() async {
    final tmdbService = TmdbService();
    final trailerKey = await tmdbService.fetchMovieTrailer(widget.movie.id);
    if (trailerKey != null) {
      setState(() {
        _trailerId = trailerKey;
        _showTrailer = true;
      });
    } else {
      if (!mounted) return;
      final localeProvider = context.read<LocaleProvider>();
      final snackBar = SnackBar(
        content: Text(localeProvider.translate('trailer_not_available')),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    String? backdropPath = widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty
        ? widget.movie.backdropPath
        : (widget.movie.posterPath.isNotEmpty ? widget.movie.posterPath : null);

    final String imageUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w780$backdropPath'
        : '';

    final double rating = widget.movie.voteAverage;

    return Dialog(
      backgroundColor: Colors.grey[900],
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con colore di sfondo scuro e bottone close allineato a destra senza parentesi nei commenti testuali
                Container(
                  color: Colors.grey[900],
                  padding: const EdgeInsets.only(top: 6, right: 4, left: 4, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: localeProvider.translate('close'),
                      ),
                    ],
                  ),
                ),
                // Blocca sotto: mostriamo video o immagine secondo la logica richiesta senza parentesi nei commenti testuali
                _showTrailer == true && _trailerId != null
                    ? YoutubeVideoPlayer(videoId: _trailerId!)
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: CircularProgressIndicator(color: Colors.white30),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Center(
                                  child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
                                ),
                              ),
                      ),
                // Area dettagli testuali e pulsanti
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: _loadingDirector
                            ? Row(
                                children: [
                                  Text(
                                    '${localeProvider.translate('directed_by')} ',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFCCCCCC),
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:2, right:2),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCCCCC)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '${localeProvider.translate('directed_by')} ${(_director != null && _director!.isNotEmpty)
                                        ? _director!
                                        : localeProvider.translate('unknown')}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFD600), size: 24),
                          const SizedBox(width: 6),
                          // Sostituito il Text qui con la nuova logica richiesta
                          Text(
                            rating > 0
                                ? rating.toStringAsFixed(1)
                                : context.watch<LocaleProvider>().translate('not_available_short'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.movie.overview.trim().isNotEmpty
                            ? widget.movie.overview
                            : localeProvider.translate('no_overview_available'),
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
                      // Replaced Row+Expanded buttons with a Wrap layout for responsive multi-line buttons
                      Wrap(
                        spacing: 10, // Spazio orizzontale tra i pulsanti
                        runSpacing: 10, // Spazio verticale tra le righe
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: 165, // Ogni pulsante copre una larghezza fissa per migliore impaginazione su 2 colonne
                            child: Consumer<FavoritesProvider>(
                              builder: (context, favoritesProvider, _) {
                                final isFavorite = favoritesProvider.isFavorite(widget.movie);
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    favoritesProvider.toggleFavorite(widget.movie);
                                  },
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isFavorite
                                        ? localeProvider.translate('remove_from_favorites')
                                        : context.read<LocaleProvider>().translate('add_to_favorites'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                          SizedBox(
                            width: 165,
                            child: Consumer<WatchlistProvider>(
                              builder: (context, watchlistProvider, _) {
                                final isInWatchlist = watchlistProvider.isInWatchlist(widget.movie);
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    watchlistProvider.toggleWatchlist(widget.movie);
                                  },
                                  icon: Icon(
                                    isInWatchlist ? Icons.bookmark_added : Icons.bookmark_add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isInWatchlist
                                        ? localeProvider.translate('remove')
                                        : localeProvider.translate('watchlist'),
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
                          SizedBox(
                            width: 165,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _launchTrailer();
                              },
                              icon: const Icon(Ionicons.playOutline, color: Colors.white),
                              label: Text(
                                localeProvider.translate('trailer'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
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
      ),
    );
  }
}