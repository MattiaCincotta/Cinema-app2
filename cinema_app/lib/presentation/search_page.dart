import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'movie_details_dialog.dart';
import '../presentation/widgets/filter_bottom_sheet.dart';
import '../providers/locale_provider.dart';
import '../providers/search_provider.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final TextEditingController _directorController;

  // Generi e anni unici usati come filtri
  final Map<String, int> _genres = {
    'Azione': 28,
    'Commedia': 35,
    'Drama': 18,
    'Fantasy': 14,
    'Horror': 27,
    'Romance': 10749,
    'Sci-Fi': 878,
    'Thriller': 53,
  };
  final List<String> _years =
      List<String>.generate(30, (i) => (DateTime.now().year - i).toString());

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _directorController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<SearchProvider>();
        provider.search(widget.initialQuery!.trim());
      });
    }
  }

  void _onScroll() {
    final provider = context.read<SearchProvider>();
    final scrollPosition = _scrollController.position;
    if (provider.hasMore &&
        !provider.isFetchingMore &&
        !provider.isLoading &&
        scrollPosition.pixels >= scrollPosition.maxScrollExtent - 200) {
      provider.fetchNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _directorController.dispose();
    super.dispose();
  }

  Future<void> _openFilterModal() async {
    final provider = context.read<SearchProvider>();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: const Color(0xFF232338),
      builder: (context) {
        return FilterBottomSheet(
          initialGenre: provider.selectedGenre,
          initialYear: provider.selectedYear,
          initialRating: provider.selectedRating,
          // Se serve un filtro regista, va aggiunto a SearchProvider
          initialDirector: null,
          genres: _genres,
          years: _years,
        );
      },
    );

    if (result != null) {
      String? selectedGenre = result['genre'] as String?;
      String? selectedYear = result['year'] as String?;
      double selectedRating = (result['rating'] ?? 0) is double
          ? result['rating']
          : (result['rating'] is num
              ? (result['rating'] as num).toDouble()
              : 0.0);
      // Supporto per director solo se gestito a livello di provider
      // String director = result['director'] ?? '';
      // provider.applyFilters(genre: selectedGenre, year: selectedYear, rating: selectedRating, director: director, genresMap: _genres);

      // Solo i filtri forniti da SearchProvider
      provider.setSelectedGenre(selectedGenre);
      provider.setSelectedYear(selectedYear);
      provider.setSelectedRating(selectedRating);
      provider.search(provider.searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final searchProvider = context.watch<SearchProvider>();
    final List<dynamic> searchResults = searchProvider.searchResults;
    final bool isLoading = searchProvider.isLoading;
    final bool isFetchingMore = searchProvider.isFetchingMore;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Ionicons.chevronBackOutline,
            color: Colors.white.withAlpha((0.9 * 255).toInt()),
       
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          tooltip: localeProvider.translate('search'),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          cursorColor: Colors.white,
          autofocus: true,
          decoration: InputDecoration(
            hintText: localeProvider.translate('search'),
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            final provider = context.read<SearchProvider>();
            provider.search(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.optionsOutline,
              color: Colors.white.withAlpha((0.9 * 255).toInt()),
         
              size: 24,
            ),
            tooltip: localeProvider.translate('favorites'),
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (searchResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Ionicons.searchOutline,
                            size: 48,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localeProvider.translate('search'),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = (constraints.maxWidth / 170).floor();
                      if (crossAxisCount < 2) crossAxisCount = 2;
                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              controller: _scrollController,
                              itemCount: searchResults.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 18,
                                crossAxisSpacing: 18,
                                childAspectRatio: 0.66,
                              ),
                              itemBuilder: (context, index) {
                                final movie = searchResults[index];
                                final poster = movie.posterPath;

                                // Se il poster è nullo o vuoto mostra contenitore grigio scuro con testo grigio chiaro
                                if (poster == null || poster.isEmpty) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            MovieDetailsDialog(movie: movie),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: Colors.grey[900],
                                        child: Center(
                                          child: Text(
                                            localeProvider.translate('watchlist'),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final imageUrl = poster.startsWith('/')
                                    ? 'https://image.tmdb.org/t/p/w500$poster'
                                    : 'https://image.tmdb.org/t/p/w500/$poster';

                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          MovieDetailsDialog(movie: movie),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[850],
                                          child: const Icon(
                                            Icons.error,
                                            size: 50,
                                            color: Colors.white24,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: Colors.grey[900],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isFetchingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )),
    );
  }
}