import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'movie_model.g.dart';

/// Represents a VOD movie
@HiveType(typeId: 1)
class MovieModel extends Equatable {
  const MovieModel({
    required this.id,
    required this.title,
    this.streamUrl,
    this.posterUrl,
    this.backdropUrl,
    this.plot,
    this.year,
    this.duration,
    this.rating,
    this.genres,
    this.director,
    this.cast,
    this.category,
    this.containerExtension,
    this.isFavorite = false,
    this.isLocked = false,
    this.watchProgress,
    this.lastWatched,
    this.metadata,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? streamUrl;

  @HiveField(3)
  final String? posterUrl;

  @HiveField(4)
  final String? backdropUrl;

  @HiveField(5)
  final String? plot;

  @HiveField(6)
  final int? year;

  @HiveField(7)
  final int? duration; // in minutes

  @HiveField(8)
  final double? rating;

  @HiveField(9)
  final List<String>? genres;

  @HiveField(10)
  final String? director;

  @HiveField(11)
  final List<String>? cast;

  @HiveField(12)
  final String? category;

  @HiveField(13)
  final String? containerExtension;

  @HiveField(14)
  final bool isFavorite;

  @HiveField(15)
  final bool isLocked;

  @HiveField(16)
  final Duration? watchProgress;

  @HiveField(17)
  final DateTime? lastWatched;

  @HiveField(18)
  final Map<String, dynamic>? metadata;

  MovieModel copyWith({
    String? id,
    String? title,
    String? streamUrl,
    String? posterUrl,
    String? backdropUrl,
    String? plot,
    int? year,
    int? duration,
    double? rating,
    List<String>? genres,
    String? director,
    List<String>? cast,
    String? category,
    String? containerExtension,
    bool? isFavorite,
    bool? isLocked,
    Duration? watchProgress,
    DateTime? lastWatched,
    Map<String, dynamic>? metadata,
  }) =>
      MovieModel(
        id: id ?? this.id,
        title: title ?? this.title,
        streamUrl: streamUrl ?? this.streamUrl,
        posterUrl: posterUrl ?? this.posterUrl,
        backdropUrl: backdropUrl ?? this.backdropUrl,
        plot: plot ?? this.plot,
        year: year ?? this.year,
        duration: duration ?? this.duration,
        rating: rating ?? this.rating,
        genres: genres ?? this.genres,
        director: director ?? this.director,
        cast: cast ?? this.cast,
        category: category ?? this.category,
        containerExtension: containerExtension ?? this.containerExtension,
        isFavorite: isFavorite ?? this.isFavorite,
        isLocked: isLocked ?? this.isLocked,
        watchProgress: watchProgress ?? this.watchProgress,
        lastWatched: lastWatched ?? this.lastWatched,
        metadata: metadata ?? this.metadata,
      );

  factory MovieModel.fromXtream(Map<String, dynamic> json, String baseUrl) {
    final streamId = json['stream_id']?.toString() ?? '';
    final ext = json['container_extension']?.toString() ?? 'mp4';
    return MovieModel(
      id: streamId,
      title: json['name']?.toString() ?? '',
      streamUrl: '$baseUrl/movie/$streamId.$ext',
      posterUrl: json['stream_icon']?.toString(),
      backdropUrl: json['cover_big']?.toString(),
      plot: json['plot']?.toString(),
      year: int.tryParse(json['year']?.toString() ?? ''),
      duration: int.tryParse(json['duration']?.toString() ?? ''),
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      genres: (json['genre'] as String?)?.split(',').map((e) => e.trim()).toList(),
      director: json['director']?.toString(),
      cast: (json['cast'] as String?)?.split(',').map((e) => e.trim()).toList(),
      category: json['category_id']?.toString(),
      containerExtension: ext,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'streamUrl': streamUrl,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'plot': plot,
        'year': year,
        'duration': duration,
        'rating': rating,
        'genres': genres,
        'director': director,
        'cast': cast,
        'category': category,
        'containerExtension': containerExtension,
        'isFavorite': isFavorite,
        'isLocked': isLocked,
        'watchProgress': watchProgress?.inMilliseconds,
        'lastWatched': lastWatched?.toIso8601String(),
        'metadata': metadata,
      };

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
        id: json['id'] as String,
        title: json['title'] as String,
        streamUrl: json['streamUrl'] as String?,
        posterUrl: json['posterUrl'] as String?,
        backdropUrl: json['backdropUrl'] as String?,
        plot: json['plot'] as String?,
        year: json['year'] as int?,
        duration: json['duration'] as int?,
        rating: (json['rating'] as num?)?.toDouble(),
        genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
        director: json['director'] as String?,
        cast: (json['cast'] as List<dynamic>?)?.cast<String>(),
        category: json['category'] as String?,
        containerExtension: json['containerExtension'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        watchProgress: json['watchProgress'] != null
            ? Duration(milliseconds: json['watchProgress'] as int)
            : null,
        lastWatched: json['lastWatched'] != null
            ? DateTime.parse(json['lastWatched'] as String)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Display year string
  String get yearString => year?.toString() ?? '';

  /// Display duration string (e.g., "2h 15m")
  String get durationString {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Watch progress percentage (0.0 to 1.0)
  double get watchProgressPercent {
    if (watchProgress == null || duration == null || duration == 0) {
      return 0.0;
    }
    return watchProgress!.inMinutes / duration!;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        streamUrl,
        posterUrl,
        backdropUrl,
        plot,
        year,
        duration,
        rating,
        genres,
        director,
        cast,
        category,
        containerExtension,
        isFavorite,
        isLocked,
        watchProgress,
        lastWatched,
        metadata,
      ];
}
