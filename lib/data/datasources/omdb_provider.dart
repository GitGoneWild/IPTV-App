import '../../core/services/http_service.dart';
import 'metadata_provider.dart';

/// Open Movie Database (OMDb) metadata provider
/// Uses the free tier which requires an API key but offers limited free requests
/// 
/// Note: This is a placeholder implementation. To use OMDb:
/// 1. Get a free API key from http://www.omdbapi.com/apikey.aspx
/// 2. Set the OMDB_API_KEY environment variable or configure in settings
/// 
/// For truly free, no-API-key sources, consider:
/// - Wikidata (via MediaWiki API)
/// - The Open Movie Database Community Edition
/// - User-contributed metadata
class OmdbProvider implements MetadataProvider {
  OmdbProvider({
    HttpService? httpService,
    String? apiKey,
  }) : _http = httpService ?? HttpService(),
       _apiKey = _validateApiKey(apiKey);

  final HttpService _http;
  final String? _apiKey;

  static const _baseUrl = 'https://www.omdbapi.com';
  
  /// Validate API key format (alphanumeric, 8 characters)
  /// Returns null if invalid, otherwise returns the trimmed key
  static String? _validateApiKey(String? key) {
    if (key == null || key.isEmpty) return null;
    final trimmed = key.trim();
    // OMDb API keys are typically 8 alphanumeric characters
    if (trimmed.length < 8 || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmed)) {
      return null;
    }
    return trimmed;
  }

  bool get _hasApiKey => _apiKey != null;

  @override
  Future<MovieMetadata?> getMovieMetadata(String title, {int? year}) async {
    if (!_hasApiKey) return null;

    try {
      final params = <String, String>{
        'apikey': _apiKey!,
        't': title,
        'type': 'movie',
      };
      if (year != null) {
        params['y'] = year.toString();
      }

      final response = await _http.get(_baseUrl, queryParameters: params);
      final data = response.data as Map<String, dynamic>;

      if (data['Response'] == 'False') return null;

      return MovieMetadata(
        title: data['Title'] as String?,
        year: int.tryParse(data['Year']?.toString() ?? ''),
        plot: data['Plot'] as String?,
        posterUrl: data['Poster'] != 'N/A' ? data['Poster'] as String? : null,
        rating: double.tryParse(data['imdbRating']?.toString() ?? ''),
        genres: (data['Genre'] as String?)?.split(', '),
        runtime: _parseRuntime(data['Runtime'] as String?),
        director: data['Director'] as String?,
        cast: (data['Actors'] as String?)?.split(', '),
        imdbId: data['imdbID'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SeriesMetadata?> getSeriesMetadata(String title) async {
    if (!_hasApiKey) return null;

    try {
      final response = await _http.get(
        _baseUrl,
        queryParameters: {
          'apikey': _apiKey!,
          't': title,
          'type': 'series',
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['Response'] == 'False') return null;

      return SeriesMetadata(
        title: data['Title'] as String?,
        year: int.tryParse(data['Year']?.toString().split('–').first ?? ''),
        plot: data['Plot'] as String?,
        posterUrl: data['Poster'] != 'N/A' ? data['Poster'] as String? : null,
        rating: double.tryParse(data['imdbRating']?.toString() ?? ''),
        genres: (data['Genre'] as String?)?.split(', '),
        cast: (data['Actors'] as String?)?.split(', '),
        imdbId: data['imdbID'] as String?,
        totalSeasons: int.tryParse(data['totalSeasons']?.toString() ?? ''),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MovieMetadata>> searchMovies(String query) async {
    if (!_hasApiKey) return [];

    try {
      final response = await _http.get(
        _baseUrl,
        queryParameters: {
          'apikey': _apiKey!,
          's': query,
          'type': 'movie',
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['Response'] == 'False') return [];

      final results = data['Search'] as List<dynamic>;
      return results.map((item) {
        final movie = item as Map<String, dynamic>;
        return MovieMetadata(
          title: movie['Title'] as String?,
          year: int.tryParse(movie['Year']?.toString() ?? ''),
          posterUrl:
              movie['Poster'] != 'N/A' ? movie['Poster'] as String? : null,
          imdbId: movie['imdbID'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SeriesMetadata>> searchSeries(String query) async {
    if (!_hasApiKey) return [];

    try {
      final response = await _http.get(
        _baseUrl,
        queryParameters: {
          'apikey': _apiKey!,
          's': query,
          'type': 'series',
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['Response'] == 'False') return [];

      final results = data['Search'] as List<dynamic>;
      return results.map((item) {
        final series = item as Map<String, dynamic>;
        return SeriesMetadata(
          title: series['Title'] as String?,
          year: int.tryParse(series['Year']?.toString().split('–').first ?? ''),
          posterUrl:
              series['Poster'] != 'N/A' ? series['Poster'] as String? : null,
          imdbId: series['imdbID'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  int? _parseRuntime(String? runtime) {
    if (runtime == null || runtime == 'N/A') return null;
    final match = RegExp(r'(\d+)').firstMatch(runtime);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}
