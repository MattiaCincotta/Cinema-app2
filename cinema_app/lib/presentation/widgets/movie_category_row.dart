import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; // Required for context.watch<>
import '../../data/tmdb_service.dart';
import '../widgets/hover_movie_card.dart';
import '../movie_details_dialog.dart';
import '../category_page.dart';
import '../../providers/locale_provider.dart'; // Assuming your LocaleProvider is here

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
    super.key,
  });

  @override
  State<MovieCategoryRow> createState() => _MovieCategoryRowState();
}

class _MovieCategoryRowState extends State<MovieCategoryRow> {
  Future<List<Movie>> Function(int) _resolveFetcher() {
    final tmdb = TmdbService();
    final lower = widget.title.toLowerCase();
    if (lower.contains('popolari')) {
      return (page) => tmdb.getPopularMovies(page: page);
    } else if (lower.contains('cinema') ||
        lower.contains('in sala') ||
        lower.contains('uscite')) {
      return (page) => tmdb.getNowPlayingMovies(page: page);
    } else if (lower.contains('top rated') || lower.contains('votati')) {
      return (page) => tmdb.getTopRatedMovies(page: page);
    } else if (lower.contains('prossimi') ||
        lower.contains('presto') ||
        lower.contains('arrivo')) {
      return (page) => tmdb.getUpcomingMovies(page: page);
    }
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
              Container(
                width: 4,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2B37),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
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
                    children: [
                      Text(
                        context.watch<LocaleProvider>().translate('see_all'),
                        style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: Color(0xFFCCCCCC),
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
          height: 200, // Abbassa l'altezza totale della riga
          child: isEmpty
              ? const Center(
                  child: Text('Nessun film trovato.',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.movies.length > 12
                      ? 12
                      : widget.movies.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final movie = widget.movies[index];
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.28, // 28% dello schermo (~3.5 cards visibili)
                      margin: const EdgeInsets.only(right: 8),
                      child: HoverMovieCard(
                        movie: movie,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => MovieDetailsDialog(movie: movie),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}