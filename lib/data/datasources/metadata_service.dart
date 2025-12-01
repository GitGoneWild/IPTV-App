import '../models/movie_model.dart';
import '../models/series_model.dart';
import 'metadata_provider.dart';
import 'omdb_provider.dart';

/// Metadata service that aggregates multiple metadata providers
/// and provides a unified interface for metadata enrichment
class MetadataService {
  MetadataService({
    List<MetadataProvider>? providers,
  }) : _providers = providers ?? [];

  final List<MetadataProvider> _providers;

  // Singleton with lazy initialization
  static MetadataService? _instance;
  static MetadataService get instance {
    _instance ??= MetadataService(
      providers: [
        // Add providers here as they are configured
        // OmdbProvider(apiKey: 'YOUR_API_KEY'),
      ],
    );
    return _instance!;
  }

  /// Add a metadata provider
  void addProvider(MetadataProvider provider) {
    _providers.add(provider);
  }

  /// Remove a metadata provider
  void removeProvider(MetadataProvider provider) {
    _providers.remove(provider);
  }

  /// Configure OMDB provider with API key
  void configureOmdb(String apiKey) {
    // Remove existing OMDB provider if any
    _providers.removeWhere((p) => p is OmdbProvider);
    _providers.add(OmdbProvider(apiKey: apiKey));
  }

  /// Enrich a movie with metadata from available providers
  /// Tries each provider in order until one returns data
  Future<MovieModel> enrichMovie(MovieModel movie) async {
    if (_providers.isEmpty) return movie;

    for (final provider in _providers) {
      try {
        final metadata = await provider.getMovieMetadata(
          movie.title,
          year: movie.year,
        );
        if (metadata != null) {
          return metadata.applyTo(movie);
        }
      } catch (e) {
        // Continue to next provider on error
        continue;
      }
    }

    return movie;
  }

  /// Enrich a series with metadata from available providers
  Future<SeriesModel> enrichSeries(SeriesModel series) async {
    if (_providers.isEmpty) return series;

    for (final provider in _providers) {
      try {
        final metadata = await provider.getSeriesMetadata(series.title);
        if (metadata != null) {
          return metadata.applyTo(series);
        }
      } catch (e) {
        // Continue to next provider on error
        continue;
      }
    }

    return series;
  }

  /// Batch enrich multiple movies
  Future<List<MovieModel>> enrichMovies(
    List<MovieModel> movies, {
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    if (_providers.isEmpty) return movies;

    final enrichedMovies = <MovieModel>[];

    for (var i = 0; i < movies.length; i += batchSize) {
      final batch = movies.skip(i).take(batchSize).toList();
      final enrichedBatch = await Future.wait(
        batch.map(enrichMovie),
      );
      enrichedMovies.addAll(enrichedBatch);

      // Add delay between batches to avoid rate limiting
      if (i + batchSize < movies.length) {
        await Future.delayed(delay);
      }
    }

    return enrichedMovies;
  }

  /// Batch enrich multiple series
  Future<List<SeriesModel>> enrichSeriesList(
    List<SeriesModel> seriesList, {
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    if (_providers.isEmpty) return seriesList;

    final enrichedSeries = <SeriesModel>[];

    for (var i = 0; i < seriesList.length; i += batchSize) {
      final batch = seriesList.skip(i).take(batchSize).toList();
      final enrichedBatch = await Future.wait(
        batch.map(enrichSeries),
      );
      enrichedSeries.addAll(enrichedBatch);

      // Add delay between batches to avoid rate limiting
      if (i + batchSize < seriesList.length) {
        await Future.delayed(delay);
      }
    }

    return enrichedSeries;
  }

  /// Search for movie metadata
  Future<List<MovieMetadata>> searchMovies(String query) async {
    for (final provider in _providers) {
      try {
        final results = await provider.searchMovies(query);
        if (results.isNotEmpty) {
          return results;
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  /// Search for series metadata
  Future<List<SeriesMetadata>> searchSeries(String query) async {
    for (final provider in _providers) {
      try {
        final results = await provider.searchSeries(query);
        if (results.isNotEmpty) {
          return results;
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }
}
