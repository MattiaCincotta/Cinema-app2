import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String? backdropPath;
  final String? director; // Indica anche il regista se fornito dal JSON

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.backdropPath,
    this.director,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      backdropPath: json['backdrop_path'] as String?,
      director: json['director'] as String?,
    );
  }
}

class TmdbService {
  // Recupera la chiave API TMDB dall'ambiente
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  // Metodo centralizzato per effettuare richieste e restituire la lista dei Movie
  Future<List<Movie>> _fetchMovieList(
    String endpoint, {
    int page = 1,
    String language = 'it-IT',
  }) async {
    // La pagina va aggiunta usando parametro query valido &page=x se in endpoint c'è già un ?
    String url;
    if (endpoint.contains('?')) {
      // endpoint già contiene query, aggiungi &page=, &language= solo se non già presente
      url = endpoint.contains('api_key=')
          ? '$endpoint&page=$page'
          : '$endpoint&api_key=$apiKey&page=$page';
      if (!url.contains('language=')) {
        url += '&language=$language';
      }
    } else {
      // endpoint senza parametri, aggiungi ?api_key=...&page=x&language=...
      url = '$endpoint?api_key=$apiKey&page=$page&language=$language';
    }
    // Genera finalUrl evitando duplicazioni di dominio
    final String finalUrl = url.startsWith('http') ? url : 'https://api.themoviedb.org/3${url.startsWith('/') ? '' : '/'}$url';
    print('URL FINALE RICHIESTO: $finalUrl');
    try {
      final response = await http.get(Uri.parse(finalUrl));
      print('STATUS CODE: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Errore nella richiesta HTTP: Status ${response.statusCode}');
      }
      try {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> resultsList = data['results'] as List<dynamic>? ?? [];
        // Decodifica risultati solo sulla chiave results e ogni voce passa da Movie.fromJson. Altri dati ignorati completamente
        return resultsList.map((item) => Movie.fromJson(item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map))).toList();
      } catch (e) {
        // Errore di parsing della risposta HTTP o estrazione lista film, url richiesto stampato in console. Vietato usare caratteri di parentesi nei commenti testuali
        print('Errore di parsing della risposta HTTP o estrazione lista film per url richiesto: $url');
        print('Eccezione: $e');
        return <Movie>[];
      }
    } catch (e) {
      print('Eccezione esatta in catch generale: $e');
      throw Exception('Impossibile recuperare la lista dei film: $e');
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film popolari usando endpoint esatto per popolari
    return _fetchMovieList('/movie/popular', page: page, language: language);
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film più votati usando endpoint esatto per top rated
    return _fetchMovieList('/movie/top_rated', page: page, language: language);
  }

  Future<List<Movie>> getHorrorMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film horror usando discover e filtro con_genres uguale a 27
    return _fetchMovieList('/discover/movie?with_genres=27', page: page, language: language);
  }

  Future<List<Movie>> getActionMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film d'azione usando discover e filtro con_genres uguale a 28
    return _fetchMovieList('/discover/movie?with_genres=28', page: page, language: language);
  }

  Future<List<Movie>> getComedyMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista delle commedie usando discover e filtro con_genres uguale a 35
    return _fetchMovieList('/discover/movie?with_genres=35', page: page, language: language);
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1, String language = 'it-IT'}) {
    // Restituisce i film per un genere generico tramite discover con parametro with_genres
    return _fetchMovieList('/discover/movie?with_genres=$genreId', page: page, language: language);
  }

  // Recupera dettagli completi del film e crediti tramite endpoint specifico
  Future<Map<String, dynamic>?> fetchMovieDetails(int movieId, {String language = 'it-IT'}) async {
    final String endpoint = '/movie/$movieId?append_to_response=credits&language=$language';
    try {
      // Si invoca l'endpoint usando la logica base di richiesta, aggiungendo manualmente api_key se serve
      String url;
      if (endpoint.contains('?')) {
        url = endpoint.contains('api_key=') ? endpoint : '$endpoint&api_key=$apiKey';
      } else {
        url = '$endpoint?api_key=$apiKey';
      }
      final String finalUrl = url.startsWith('http') ? url : 'https://api.themoviedb.org/3${url.startsWith('/') ? '' : '/'}$url';
      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode != 200) {
        print('Errore di richiesta HTTP film dettaglio URL richiesto: $finalUrl');
        print('Status: ${response.statusCode}');
        return null;
      }
      try {
        final Map<String, dynamic> jsonDettagli = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonDettagli;
      } catch (e) {
        print('Errore parsing risposta dettaglio film url richiesto: $finalUrl');
        print('Eccezione: $e');
        return null;
      }
    } catch (e) {
      print('Eccezione esatta in catch generale dettagli film: $e');
      return null;
    }
  }

  // Metodo privato per recuperare il regista di un film. Usato solo se richiesto da codice esterno
  Future<String> _fetchDirector(int movieId, {String language = 'it-IT'}) async {
    final url = 'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey&language=$language';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        // Fallita richiesta restituisce stringa vuota
        return '';
      }
      final credits = jsonDecode(response.body) as Map<String, dynamic>;
      final crew = credits['crew'] as List<dynamic>? ?? [];
      for (final c in crew) {
        if ((c is Map<String, dynamic>) && (c['job'] == 'Director')) {
          return c['name'] as String? ?? '';
        }
      }
      // Regista non trovato
      return '';
    } catch (_) {
      // Errore recupero regista
      return '';
    }
  }

  // Nuovo metodo per recuperare la chiave del trailer YouTube di un film
  Future<String?> fetchMovieTrailer(int movieId, {String language = 'it-IT'}) async {
    // Chiede i video del film tramite endpoint appropriato e cerca il trailer YouTube
    final String endpoint = '/movie/$movieId/videos?api_key=$apiKey&language=$language';
    final String finalUrl = endpoint.startsWith('http')
        ? endpoint
        : 'https://api.themoviedb.org/3${endpoint.startsWith('/') ? '' : '/'}$endpoint';
    try {
      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode != 200) {
        // Errore richiesta video trailer
        return null;
      }
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
      for (final video in results) {
        final m = video as Map<String, dynamic>;
        if (m['site'] == 'YouTube' && m['type'] == 'Trailer') {
          return m['key'] as String?;
        }
      }
      // Nessun trailer YouTube trovato
      return null;
    } catch (e) {
      // Errore generico nella chiamata trailer
      print('Errore durante recupero trailer YouTube per movieId $movieId: $e');
      return null;
    }
  }

  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
    String language = 'it-IT',
  }) {
    // Ricerca film tramite query testuale
    final encodedQuery = Uri.encodeComponent(query);
    return _fetchMovieList('/search/movie?query=$encodedQuery', page: page, language: language);
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film in uscita prossimamente
    return _fetchMovieList('/movie/upcoming', page: page, language: language);
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1, String language = 'it-IT'}) {
    // Restituisce la lista dei film attualmente in sala
    return _fetchMovieList('/movie/now_playing', page: page, language: language);
  }

  // Filtro film con priorità a ricerca testuale, altrimenti discover
  Future<List<Movie>> filterMovies({
    int? genreId,
    int? year,
    double? minRating,
    String? director,
    String? query,
    int page = 1,
    String language = 'it-IT',
  }) async {
    // Usa solo la query testuale se indicata
    if (query != null && query.trim().isNotEmpty) {
      final encodedQuery = Uri.encodeComponent(query.trim());
      return _fetchMovieList('/search/movie?query=$encodedQuery', page: page, language: language);
    }

    int? directorId;
    if (director != null && director.trim().isNotEmpty) {
      final searchPersonUrl = 'https://api.themoviedb.org/3/search/person?api_key=$apiKey&language=$language&query=${Uri.encodeComponent(director)}';
      final directorResponse = await http.get(Uri.parse(searchPersonUrl));
      if (directorResponse.statusCode != 200) {
        return <Movie>[];
      }
      final personResult = jsonDecode(directorResponse.body) as Map<String, dynamic>;
      final results = personResult['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) {
        return <Movie>[];
      }
      directorId = results.first['id'] as int?;
      if (directorId == null) {
        return <Movie>[];
      }
    }

    final buffer = StringBuffer('/discover/movie?sort_by=popularity.desc&language=$language');
    if (genreId != null) {
      buffer.write('&with_genres=${genreId.toString()}');
    }
    if (year != null) {
      buffer.write('&primary_release_year=${Uri.encodeComponent(year.toString())}');
    }
    if (minRating != null && minRating > 0.0) {
      buffer.write('&vote_average.gte=${Uri.encodeComponent(minRating.toString())}');
    }
    if (directorId != null) {
      buffer.write('&with_crew=$directorId');
    }

    return _fetchMovieList(buffer.toString(), page: page, language: language);
  }
}
