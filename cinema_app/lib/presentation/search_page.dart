import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../data/tmdb_service.dart';
import 'movie_details_dialog.dart';
import '../utils/parser_utils.dart' show ParserUtils;
import '../presentation/widgets/filter_bottom_sheet.dart';
import '../providers/locale_provider.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TmdbService _tmdbService = TmdbService();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  late TextEditingController _searchController;

  String? _selectedGenre;
  String? _selectedYear;
  double _selectedRating = 0;
  late TextEditingController _directorController;

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

  // Dichiarazione dello ScrollController per la paginazione infinita
  late final ScrollController _scrollController;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreResults = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _directorController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchQuery = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerInitialSearch();
      });
    }
  }

  // Listener per gestione paginazione infinita
  void _onScroll() {
    // Se l'utente si avvicina a 200 pixel dalla fine ed è consentito caricare ancora risultati, procedi con la paginazione
    if (_hasMoreResults &&
        !_isFetchingMore &&
        !_isLoading &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _triggerInitialSearch() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreResults = true;
    });
    try {
      final results = await _tmdbService.searchMovies(_searchQuery, page: 1);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _currentPage = 1;
        _hasMoreResults = results.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasMoreResults = false;
      });
    }
  }

  Future<void> _onSearchChanged(String value) async {
    _searchQuery = value;
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasMoreResults = true;
        _currentPage = 1;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreResults = true;
    });
    try {
      final results = await _tmdbService.searchMovies(value, page: 1);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _currentPage = 1;
        _hasMoreResults = results.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasMoreResults = false;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMoreResults) return;
    setState(() {
      _isFetchingMore = true;
    });
    try {
      final nextPage = _currentPage + 1;
      List<Movie> newResults = [];
      // Decidi se chiamare la search o la filter API in base alla presenza di filtri avanzati
      if (_selectedGenre != null || _selectedYear != null || _selectedRating > 0 || _directorController.text.trim().isNotEmpty) {
        int? genreId;
        if (_selectedGenre != null && _genres[_selectedGenre!] != null) {
          genreId = _genres[_selectedGenre!];
        }
        newResults = await _tmdbService.filterMovies(
          genreId: genreId,
          year: _selectedYear != null ? int.tryParse(_selectedYear!) : null,
          minRating: _selectedRating,
          director: _directorController.text.trim().isEmpty ? null : _directorController.text.trim(),
          query: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
          page: nextPage,
        );
      } else {
        newResults = await _tmdbService.searchMovies(_searchQuery, page: nextPage);
      }

      setState(() {
        if (newResults.isNotEmpty) {
          _searchResults.addAll(newResults);
          _currentPage = nextPage;
        } 
        // Se il numero di risultati nuovi è zero, niente più pagine disponibili
        _hasMoreResults = newResults.isNotEmpty;
        _isFetchingMore = false;
      });
    } catch (_) {
      setState(() {
        _isFetchingMore = false;
        _hasMoreResults = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _directorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: const Color(0xFF232338),
      builder: (context) {
        return FilterBottomSheet(
          initialGenre: _selectedGenre,
          initialYear: _selectedYear,
          initialRating: _selectedRating,
          initialDirector: _directorController.text,
          genres: _genres,
          years: _years,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedGenre = result['genre'] as String?;
        _selectedYear = result['year'] as String?;
        _selectedRating = (result['rating'] ?? 0) is double
            ? result['rating']
            : (result['rating'] is num
                ? (result['rating'] as num).toDouble()
                : 0.0);
        _directorController.text = result['director'] ?? '';
        _isLoading = true;
        _currentPage = 1;
        _hasMoreResults = true;
      });

      try {
        // Trasforma il genere selezionato in identificatore numerico per il filtro se disponibile
        int? genreId;
        if (_selectedGenre != null && _genres[_selectedGenre!] != null) {
          genreId = _genres[_selectedGenre!];
        }
        // Seleziona l'anno intero se _selectedYear valorizzato altrimenti passa null
        // Vietato usare qualsiasi tipo di carattere di parentesi nei commenti testuali
        final filteredResults = await _tmdbService.filterMovies(
          genreId: genreId,
          year: _selectedYear != null ? int.tryParse(_selectedYear!) : null,
          minRating: _selectedRating,
          director: _directorController.text.trim().isEmpty
              ? null
              : _directorController.text.trim(),
          query: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
          page: 1,
        );
        setState(() {
          _searchResults = filteredResults;
          _isLoading = false;
          _currentPage = 1;
          _hasMoreResults = filteredResults.isNotEmpty;
        });
      } catch (_) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _hasMoreResults = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Ionicons.chevronBackOutline,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          tooltip: localeProvider.translate('search'), // dynamic translation for tooltip
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          cursorColor: Colors.white,
          autofocus: true,
          decoration: InputDecoration(
            hintText: localeProvider.translate('search'), // dynamic translation for hint
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.optionsOutline,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
            tooltip: localeProvider.translate('favorites'), // example: translate favorites as "Filtri"
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_searchResults.isEmpty
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
                            localeProvider.translate('search'), // translate "search" context
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
                              itemCount: _searchResults.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 18,
                                crossAxisSpacing: 18,
                                childAspectRatio: 0.66,
                              ),
                              itemBuilder: (context, index) {
                                final movie = _searchResults[index];
                                final poster = movie.posterPath;

                                // Se il poster è nullo o vuoto, mostra subito un contenitore grigio scuro con testo grigio chiaro
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
                                            localeProvider.translate('watchlist'), // dynamic translation for "Nessun poster"
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
                          if (_isFetchingMore)
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