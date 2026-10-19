import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');

  Future<List<Movie>> getPopularMovies() async {
    try {
      if (_apiKey.isEmpty) {
        throw StateError(
          'TMDB_API_KEY mancante. Avvia l\'app con '
          '--dart-define=TMDB_API_KEY=... oppure '
          '--dart-define-from-file=dart_defines.json',
        );
      }

      final uri = Uri.parse('$_baseUrl/movie/popular').replace(
        queryParameters: {
          'api_key': _apiKey,
        },
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Errore nel caricamento dei film: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Impossibile recuperare i film popolari: $e');
    }
  }
}
