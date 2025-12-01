import '../models/movie_model.dart';
import '../models/series_model.dart';

/// Abstract interface for metadata providers
/// This abstraction allows for easy swapping of providers in the future
abstract class MetadataProvider {
  /// Fetch movie metadata by title and optional year
  Future<MovieMetadata?> getMovieMetadata(String title, {int? year});

  /// Fetch series metadata by title
  Future<SeriesMetadata?> getSeriesMetadata(String title);

  /// Search for movies by query
  Future<List<MovieMetadata>> searchMovies(String query);

  /// Search for series by query
  Future<List<SeriesMetadata>> searchSeries(String query);
}

/// Movie metadata result
class MovieMetadata {
  const MovieMetadata({
    this.title,
    this.originalTitle,
    this.year,
    this.plot,
    this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.genres,
    this.runtime,
    this.director,
    this.cast,
    this.imdbId,
    this.tmdbId,
  });

  final String? title;
  final String? originalTitle;
  final int? year;
  final String? plot;
  final String? posterUrl;
  final String? backdropUrl;
  final double? rating;
  final List<String>? genres;
  final int? runtime;
  final String? director;
  final List<String>? cast;
  final String? imdbId;
  final int? tmdbId;

  /// Apply metadata to an existing movie model
  MovieModel applyTo(MovieModel movie) => movie.copyWith(
        title: title ?? movie.title,
        posterUrl: posterUrl ?? movie.posterUrl,
        backdropUrl: backdropUrl ?? movie.backdropUrl,
        plot: plot ?? movie.plot,
        year: year ?? movie.year,
        duration: runtime ?? movie.duration,
        rating: rating ?? movie.rating,
        genres: genres ?? movie.genres,
        director: director ?? movie.director,
        cast: cast ?? movie.cast,
      );
}

/// Series metadata result
class SeriesMetadata {
  const SeriesMetadata({
    this.title,
    this.originalTitle,
    this.year,
    this.plot,
    this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.genres,
    this.cast,
    this.imdbId,
    this.tmdbId,
    this.totalSeasons,
    this.status,
  });

  final String? title;
  final String? originalTitle;
  final int? year;
  final String? plot;
  final String? posterUrl;
  final String? backdropUrl;
  final double? rating;
  final List<String>? genres;
  final List<String>? cast;
  final String? imdbId;
  final int? tmdbId;
  final int? totalSeasons;
  final String? status;

  /// Apply metadata to an existing series model
  SeriesModel applyTo(SeriesModel series) => series.copyWith(
        title: title ?? series.title,
        posterUrl: posterUrl ?? series.posterUrl,
        backdropUrl: backdropUrl ?? series.backdropUrl,
        plot: plot ?? series.plot,
        year: year ?? series.year,
        rating: rating ?? series.rating,
        genres: genres ?? series.genres,
        cast: cast ?? series.cast,
      );
}
