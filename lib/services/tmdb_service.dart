import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get _baseUrl => dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<Map<String, dynamic>?> searchMovie(String title) async {
    if (_apiKey.isEmpty) return null;

    try {
      final encodedTitle = Uri.encodeComponent(title);
      final url = '$_baseUrl/search/movie?api_key=$_apiKey&query=$encodedTitle';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        if (results.isNotEmpty) {
          final movie = results.first as Map<String, dynamic>;
          return _enrichMovieData(movie);
        }
      }
    } catch (e) {
      // Silently fail if TMDB is not available
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> searchTVShow(String title) async {
    if (_apiKey.isEmpty) return null;

    try {
      final encodedTitle = Uri.encodeComponent(title);
      final url = '$_baseUrl/search/tv?api_key=$_apiKey&query=$encodedTitle';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        if (results.isNotEmpty) {
          final tvShow = results.first as Map<String, dynamic>;
          return _enrichTVData(tvShow);
        }
      }
    } catch (e) {
      // Silently fail if TMDB is not available
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits,videos';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final movie = json.decode(response.body) as Map<String, dynamic>;
        return _enrichMovieData(movie);
      }
    } catch (e) {
      // Silently fail if TMDB is not available
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getTVShowDetails(int tvId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final url = '$_baseUrl/tv/$tvId?api_key=$_apiKey&append_to_response=credits,videos';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final tvShow = json.decode(response.body) as Map<String, dynamic>;
        return _enrichTVData(tvShow);
      }
    } catch (e) {
      // Silently fail if TMDB is not available
    }
    
    return null;
  }

  Map<String, dynamic> _enrichMovieData(Map<String, dynamic> movie) {
    return {
      'id': movie['id'],
      'title': movie['title'],
      'overview': movie['overview'],
      'release_date': movie['release_date'],
      'vote_average': movie['vote_average'],
      'vote_count': movie['vote_count'],
      'poster_path': movie['poster_path'] != null 
          ? '$_imageBaseUrl${movie['poster_path']}' 
          : null,
      'backdrop_path': movie['backdrop_path'] != null 
          ? '$_imageBaseUrl${movie['backdrop_path']}' 
          : null,
      'genres': movie['genres'],
      'runtime': movie['runtime'],
      'cast': _extractCast(movie['credits']),
      'directors': _extractDirectors(movie['credits']),
      'trailers': _extractTrailers(movie['videos']),
    };
  }

  Map<String, dynamic> _enrichTVData(Map<String, dynamic> tvShow) {
    return {
      'id': tvShow['id'],
      'name': tvShow['name'],
      'overview': tvShow['overview'],
      'first_air_date': tvShow['first_air_date'],
      'vote_average': tvShow['vote_average'],
      'vote_count': tvShow['vote_count'],
      'poster_path': tvShow['poster_path'] != null 
          ? '$_imageBaseUrl${tvShow['poster_path']}' 
          : null,
      'backdrop_path': tvShow['backdrop_path'] != null 
          ? '$_imageBaseUrl${tvShow['backdrop_path']}' 
          : null,
      'genres': tvShow['genres'],
      'number_of_seasons': tvShow['number_of_seasons'],
      'number_of_episodes': tvShow['number_of_episodes'],
      'cast': _extractCast(tvShow['credits']),
      'creators': tvShow['created_by'],
      'trailers': _extractTrailers(tvShow['videos']),
    };
  }

  List<Map<String, dynamic>> _extractCast(Map<String, dynamic>? credits) {
    if (credits == null || credits['cast'] == null) return [];
    
    final cast = credits['cast'] as List;
    return cast.take(10).map((person) => {
      'name': person['name'],
      'character': person['character'],
      'profile_path': person['profile_path'] != null 
          ? '$_imageBaseUrl${person['profile_path']}' 
          : null,
    }).toList();
  }

  List<Map<String, dynamic>> _extractDirectors(Map<String, dynamic>? credits) {
    if (credits == null || credits['crew'] == null) return [];
    
    final crew = credits['crew'] as List;
    return crew.where((person) => person['job'] == 'Director').map((person) => {
      'name': person['name'],
      'profile_path': person['profile_path'] != null 
          ? '$_imageBaseUrl${person['profile_path']}' 
          : null,
    }).toList();
  }

  List<Map<String, dynamic>> _extractTrailers(Map<String, dynamic>? videos) {
    if (videos == null || videos['results'] == null) return [];
    
    final results = videos['results'] as List;
    return results
        .where((video) => video['type'] == 'Trailer' && video['site'] == 'YouTube')
        .take(3)
        .map((video) => {
          'name': video['name'],
          'key': video['key'],
          'url': 'https://www.youtube.com/watch?v=${video['key']}',
        }).toList();
  }

  bool get isConfigured => _apiKey.isNotEmpty;
}