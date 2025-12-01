import 'package:equatable/equatable.dart';

/// Represents a TV series
class SeriesModel extends Equatable {
  const SeriesModel({
    required this.id,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.plot,
    this.year,
    this.rating,
    this.genres,
    this.cast,
    this.category,
    this.seasons,
    this.isFavorite = false,
    this.isLocked = false,
    this.lastWatchedEpisodeId,
    this.lastWatched,
    this.metadata,
  });

  final String id;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? plot;
  final int? year;
  final double? rating;
  final List<String>? genres;
  final List<String>? cast;
  final String? category;
  final List<SeasonModel>? seasons;
  final bool isFavorite;
  final bool isLocked;
  final String? lastWatchedEpisodeId;
  final DateTime? lastWatched;
  final Map<String, dynamic>? metadata;

  SeriesModel copyWith({
    String? id,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    String? plot,
    int? year,
    double? rating,
    List<String>? genres,
    List<String>? cast,
    String? category,
    List<SeasonModel>? seasons,
    bool? isFavorite,
    bool? isLocked,
    String? lastWatchedEpisodeId,
    DateTime? lastWatched,
    Map<String, dynamic>? metadata,
  }) =>
      SeriesModel(
        id: id ?? this.id,
        title: title ?? this.title,
        posterUrl: posterUrl ?? this.posterUrl,
        backdropUrl: backdropUrl ?? this.backdropUrl,
        plot: plot ?? this.plot,
        year: year ?? this.year,
        rating: rating ?? this.rating,
        genres: genres ?? this.genres,
        cast: cast ?? this.cast,
        category: category ?? this.category,
        seasons: seasons ?? this.seasons,
        isFavorite: isFavorite ?? this.isFavorite,
        isLocked: isLocked ?? this.isLocked,
        lastWatchedEpisodeId: lastWatchedEpisodeId ?? this.lastWatchedEpisodeId,
        lastWatched: lastWatched ?? this.lastWatched,
        metadata: metadata ?? this.metadata,
      );

  factory SeriesModel.fromXtream(Map<String, dynamic> json) => SeriesModel(
        id: json['series_id']?.toString() ?? '',
        title: json['name']?.toString() ?? '',
        posterUrl: json['cover']?.toString(),
        backdropUrl: json['backdrop_path']?.toString(),
        plot: json['plot']?.toString(),
        year: int.tryParse(json['year']?.toString() ?? ''),
        rating: double.tryParse(json['rating']?.toString() ?? ''),
        genres:
            (json['genre'] as String?)?.split(',').map((e) => e.trim()).toList(),
        cast: (json['cast'] as String?)?.split(',').map((e) => e.trim()).toList(),
        category: json['category_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'plot': plot,
        'year': year,
        'rating': rating,
        'genres': genres,
        'cast': cast,
        'category': category,
        'seasons': seasons?.map((s) => s.toJson()).toList(),
        'isFavorite': isFavorite,
        'isLocked': isLocked,
        'lastWatchedEpisodeId': lastWatchedEpisodeId,
        'lastWatched': lastWatched?.toIso8601String(),
        'metadata': metadata,
      };

  factory SeriesModel.fromJson(Map<String, dynamic> json) => SeriesModel(
        id: json['id'] as String,
        title: json['title'] as String,
        posterUrl: json['posterUrl'] as String?,
        backdropUrl: json['backdropUrl'] as String?,
        plot: json['plot'] as String?,
        year: json['year'] as int?,
        rating: (json['rating'] as num?)?.toDouble(),
        genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
        cast: (json['cast'] as List<dynamic>?)?.cast<String>(),
        category: json['category'] as String?,
        seasons: (json['seasons'] as List<dynamic>?)
            ?.map((s) => SeasonModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        isFavorite: json['isFavorite'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        lastWatchedEpisodeId: json['lastWatchedEpisodeId'] as String?,
        lastWatched: json['lastWatched'] != null
            ? DateTime.parse(json['lastWatched'] as String)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Total number of episodes across all seasons
  int get totalEpisodes =>
      seasons?.fold(0, (sum, s) => sum! + (s.episodes?.length ?? 0)) ?? 0;

  /// Total number of seasons
  int get totalSeasons => seasons?.length ?? 0;

  @override
  List<Object?> get props => [
        id,
        title,
        posterUrl,
        backdropUrl,
        plot,
        year,
        rating,
        genres,
        cast,
        category,
        seasons,
        isFavorite,
        isLocked,
        lastWatchedEpisodeId,
        lastWatched,
        metadata,
      ];
}

/// Represents a season within a series
class SeasonModel extends Equatable {
  const SeasonModel({
    required this.id,
    required this.seasonNumber,
    this.name,
    this.posterUrl,
    this.episodes,
  });

  final String id;
  final int seasonNumber;
  final String? name;
  final String? posterUrl;
  final List<EpisodeModel>? episodes;

  SeasonModel copyWith({
    String? id,
    int? seasonNumber,
    String? name,
    String? posterUrl,
    List<EpisodeModel>? episodes,
  }) =>
      SeasonModel(
        id: id ?? this.id,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        name: name ?? this.name,
        posterUrl: posterUrl ?? this.posterUrl,
        episodes: episodes ?? this.episodes,
      );

  factory SeasonModel.fromXtream(Map<String, dynamic> json) => SeasonModel(
        id: json['season_number']?.toString() ?? '',
        seasonNumber: int.tryParse(json['season_number']?.toString() ?? '') ?? 0,
        name: json['name']?.toString(),
        posterUrl: json['cover']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seasonNumber': seasonNumber,
        'name': name,
        'posterUrl': posterUrl,
        'episodes': episodes?.map((e) => e.toJson()).toList(),
      };

  factory SeasonModel.fromJson(Map<String, dynamic> json) => SeasonModel(
        id: json['id'] as String,
        seasonNumber: json['seasonNumber'] as int,
        name: json['name'] as String?,
        posterUrl: json['posterUrl'] as String?,
        episodes: (json['episodes'] as List<dynamic>?)
            ?.map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Display name (e.g., "Season 1" or custom name)
  String get displayName => name ?? 'Season $seasonNumber';

  @override
  List<Object?> get props => [id, seasonNumber, name, posterUrl, episodes];
}

/// Represents an episode within a season
class EpisodeModel extends Equatable {
  const EpisodeModel({
    required this.id,
    required this.episodeNumber,
    this.title,
    this.streamUrl,
    this.posterUrl,
    this.plot,
    this.duration,
    this.releaseDate,
    this.containerExtension,
    this.watchProgress,
    this.lastWatched,
  });

  final String id;
  final int episodeNumber;
  final String? title;
  final String? streamUrl;
  final String? posterUrl;
  final String? plot;
  final int? duration; // in minutes
  final DateTime? releaseDate;
  final String? containerExtension;
  final Duration? watchProgress;
  final DateTime? lastWatched;

  EpisodeModel copyWith({
    String? id,
    int? episodeNumber,
    String? title,
    String? streamUrl,
    String? posterUrl,
    String? plot,
    int? duration,
    DateTime? releaseDate,
    String? containerExtension,
    Duration? watchProgress,
    DateTime? lastWatched,
  }) =>
      EpisodeModel(
        id: id ?? this.id,
        episodeNumber: episodeNumber ?? this.episodeNumber,
        title: title ?? this.title,
        streamUrl: streamUrl ?? this.streamUrl,
        posterUrl: posterUrl ?? this.posterUrl,
        plot: plot ?? this.plot,
        duration: duration ?? this.duration,
        releaseDate: releaseDate ?? this.releaseDate,
        containerExtension: containerExtension ?? this.containerExtension,
        watchProgress: watchProgress ?? this.watchProgress,
        lastWatched: lastWatched ?? this.lastWatched,
      );

  factory EpisodeModel.fromXtream(
    Map<String, dynamic> json,
    String baseUrl,
  ) {
    final streamId = json['id']?.toString() ?? '';
    final ext = json['container_extension']?.toString() ?? 'mp4';
    return EpisodeModel(
      id: streamId,
      episodeNumber:
          int.tryParse(json['episode_num']?.toString() ?? '') ?? 0,
      title: json['title']?.toString(),
      streamUrl: '$baseUrl/series/$streamId.$ext',
      posterUrl: json['info']?['movie_image']?.toString(),
      plot: json['info']?['plot']?.toString(),
      duration: int.tryParse(json['info']?['duration']?.toString() ?? ''),
      releaseDate: json['info']?['releasedate'] != null
          ? DateTime.tryParse(json['info']['releasedate'] as String)
          : null,
      containerExtension: ext,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'episodeNumber': episodeNumber,
        'title': title,
        'streamUrl': streamUrl,
        'posterUrl': posterUrl,
        'plot': plot,
        'duration': duration,
        'releaseDate': releaseDate?.toIso8601String(),
        'containerExtension': containerExtension,
        'watchProgress': watchProgress?.inMilliseconds,
        'lastWatched': lastWatched?.toIso8601String(),
      };

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        id: json['id'] as String,
        episodeNumber: json['episodeNumber'] as int,
        title: json['title'] as String?,
        streamUrl: json['streamUrl'] as String?,
        posterUrl: json['posterUrl'] as String?,
        plot: json['plot'] as String?,
        duration: json['duration'] as int?,
        releaseDate: json['releaseDate'] != null
            ? DateTime.parse(json['releaseDate'] as String)
            : null,
        containerExtension: json['containerExtension'] as String?,
        watchProgress: json['watchProgress'] != null
            ? Duration(milliseconds: json['watchProgress'] as int)
            : null,
        lastWatched: json['lastWatched'] != null
            ? DateTime.parse(json['lastWatched'] as String)
            : null,
      );

  /// Display title (e.g., "Episode 1" or actual title)
  String get displayTitle => title ?? 'Episode $episodeNumber';

  /// Display duration string
  String get durationString {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Watch progress percentage
  double get watchProgressPercent {
    if (watchProgress == null || duration == null || duration == 0) {
      return 0.0;
    }
    return watchProgress!.inMinutes / duration!;
  }

  @override
  List<Object?> get props => [
        id,
        episodeNumber,
        title,
        streamUrl,
        posterUrl,
        plot,
        duration,
        releaseDate,
        containerExtension,
        watchProgress,
        lastWatched,
      ];
}
