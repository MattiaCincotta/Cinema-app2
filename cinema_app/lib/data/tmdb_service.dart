import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String? backdropPath; // Campo opzionale

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.backdropPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      backdropPath: json['backdrop_path'] as String?, // Estrazione del campo opzionale
    );
  }
}

class TmdbService {
  // Recupera la chiave, se non la trova usa una stringa vuota di fallback
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  Future<List<Movie>> getPopularMovies() async {
    try {
      final url = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=it-IT';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Errore nel caricamento dei film: ${response.statusCode}');
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

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    try {
      final url = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&language=it-IT&with_genres=$genreId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Errore nel caricamento dei film per genere: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Impossibile recuperare i film per genere: $e');
    }
  }
}
