import 'dart:convert';

import 'package:xml/xml.dart' as xml;

import '../../data/models/category_model.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/epg_model.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/series_model.dart';
import 'http_service.dart';

/// Service for Xtream Codes API integration
class XtreamService {
  XtreamService({HttpService? httpService})
      : _http = httpService ?? HttpService();

  final HttpService _http;

  /// Authenticate and get account info
  Future<XtreamAuthResult> authenticate(ProviderModel provider) async {
    if (provider.type != ProviderType.xtream) {
      throw const XtreamException('Invalid provider type');
    }

    final url = provider.getXtreamUrl('get_account_info');
    if (url == null) {
      throw const XtreamException('Invalid provider configuration');
    }

    try {
      final response = await _http.downloadJson(url);
      final data = response as Map<String, dynamic>;

      if (data.containsKey('user_info')) {
        final userInfo = data['user_info'] as Map<String, dynamic>;
        final serverInfo = data['server_info'] as Map<String, dynamic>?;

        return XtreamAuthResult(
          username: userInfo['username']?.toString() ?? '',
          status: userInfo['status']?.toString() ?? 'Unknown',
          expirationDate: userInfo['exp_date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  (int.tryParse(userInfo['exp_date'].toString()) ?? 0) * 1000,
                )
              : null,
          maxConnections:
              int.tryParse(userInfo['max_connections']?.toString() ?? ''),
          activeConnections:
              int.tryParse(userInfo['active_cons']?.toString() ?? ''),
          serverUrl: serverInfo?['url']?.toString(),
          serverPort: serverInfo?['port']?.toString(),
          serverProtocol: serverInfo?['server_protocol']?.toString(),
          timezone: serverInfo?['timezone']?.toString(),
        );
      } else {
        throw const XtreamException('Invalid response format');
      }
    } on HttpException catch (e) {
      throw XtreamException('Authentication failed: ${e.message}');
    } catch (e) {
      throw XtreamException('Authentication failed: $e');
    }
  }

  /// Get live stream categories
  Future<List<CategoryModel>> getLiveCategories(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_live_categories');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      return data
          .map(
            (e) =>
                CategoryModel.fromXtream(e as Map<String, dynamic>, CategoryType.live),
          )
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get live categories: $e');
    }
  }

  /// Get VOD categories
  Future<List<CategoryModel>> getVodCategories(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_vod_categories');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      return data
          .map(
            (e) => CategoryModel.fromXtream(
              e as Map<String, dynamic>,
              CategoryType.movie,
            ),
          )
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get VOD categories: $e');
    }
  }

  /// Get series categories
  Future<List<CategoryModel>> getSeriesCategories(
    ProviderModel provider,
  ) async {
    final url = provider.getXtreamUrl('get_series_categories');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      return data
          .map(
            (e) => CategoryModel.fromXtream(
              e as Map<String, dynamic>,
              CategoryType.series,
            ),
          )
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get series categories: $e');
    }
  }

  /// Get live streams
  Future<List<ChannelModel>> getLiveStreams(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_live_streams');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      final baseUrl =
          '${provider.baseUrl}/live/${provider.username}/${provider.password}';
      return data
          .map((e) => ChannelModel.fromXtream(e as Map<String, dynamic>, baseUrl))
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get live streams: $e');
    }
  }

  /// Get VOD streams
  Future<List<MovieModel>> getVodStreams(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_vod_streams');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      final baseUrl =
          '${provider.baseUrl}/movie/${provider.username}/${provider.password}';
      return data
          .map((e) => MovieModel.fromXtream(e as Map<String, dynamic>, baseUrl))
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get VOD streams: $e');
    }
  }

  /// Get series
  Future<List<SeriesModel>> getSeries(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_series');
    if (url == null) return [];

    try {
      final response = await _http.downloadJson(url);
      final data = response as List<dynamic>;
      return data
          .map((e) => SeriesModel.fromXtream(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw XtreamException('Failed to get series: $e');
    }
  }

  /// Get series info (seasons and episodes)
  Future<SeriesModel?> getSeriesInfo(
    ProviderModel provider,
    String seriesId,
  ) async {
    final url = '${provider.getXtreamUrl('get_series_info')}&series_id=$seriesId';

    try {
      final response = await _http.downloadJson(url);
      final data = response as Map<String, dynamic>;

      if (data.containsKey('info')) {
        final info = data['info'] as Map<String, dynamic>;
        final episodes = data['episodes'] as Map<String, dynamic>?;
        final baseUrl =
            '${provider.baseUrl}/series/${provider.username}/${provider.password}';

        final seasons = <SeasonModel>[];
        if (episodes != null) {
          for (final seasonNum in episodes.keys) {
            final seasonEpisodes = episodes[seasonNum] as List<dynamic>;
            seasons.add(
              SeasonModel(
                id: seasonNum,
                seasonNumber: int.tryParse(seasonNum) ?? 0,
                episodes: seasonEpisodes
                    .map(
                      (e) => EpisodeModel.fromXtream(
                        e as Map<String, dynamic>,
                        baseUrl,
                      ),
                    )
                    .toList(),
              ),
            );
          }
        }

        return SeriesModel(
          id: seriesId,
          title: info['name']?.toString() ?? '',
          posterUrl: info['cover']?.toString(),
          backdropUrl: info['backdrop_path']?.toString(),
          plot: info['plot']?.toString(),
          year: int.tryParse(info['year']?.toString() ?? ''),
          rating: double.tryParse(info['rating']?.toString() ?? ''),
          genres: (info['genre'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList(),
          cast: (info['cast'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList(),
          category: info['category_id']?.toString(),
          seasons: seasons,
        );
      }

      return null;
    } catch (e) {
      throw XtreamException('Failed to get series info: $e');
    }
  }

  /// Get VOD info
  Future<MovieModel?> getVodInfo(
    ProviderModel provider,
    String vodId,
  ) async {
    final url = '${provider.getXtreamUrl('get_vod_info')}&vod_id=$vodId';

    try {
      final response = await _http.downloadJson(url);
      final data = response as Map<String, dynamic>;

      if (data.containsKey('info')) {
        final info = data['info'] as Map<String, dynamic>;
        final movieData = data['movie_data'] as Map<String, dynamic>?;
        final baseUrl =
            '${provider.baseUrl}/movie/${provider.username}/${provider.password}';

        final streamId = movieData?['stream_id']?.toString() ?? vodId;
        final ext = movieData?['container_extension']?.toString() ?? 'mp4';

        return MovieModel(
          id: vodId,
          title: info['name']?.toString() ?? '',
          streamUrl: '$baseUrl/$streamId.$ext',
          posterUrl: info['movie_image']?.toString() ?? info['cover_big']?.toString(),
          backdropUrl: info['backdrop_path']?.toString(),
          plot: info['plot']?.toString() ?? info['description']?.toString(),
          year: int.tryParse(info['year']?.toString() ?? ''),
          duration: int.tryParse(info['duration']?.toString() ?? ''),
          rating: double.tryParse(info['rating']?.toString() ?? ''),
          genres: (info['genre'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList(),
          director: info['director']?.toString(),
          cast: (info['cast'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList(),
          containerExtension: ext,
        );
      }

      return null;
    } catch (e) {
      throw XtreamException('Failed to get VOD info: $e');
    }
  }

  /// Get short EPG for a stream
  Future<List<EpgModel>> getShortEpg(
    ProviderModel provider,
    String streamId, {
    int limit = 4,
  }) async {
    final url =
        '${provider.getXtreamUrl('get_short_epg')}&stream_id=$streamId&limit=$limit';

    try {
      final response = await _http.downloadJson(url);
      final data = response as Map<String, dynamic>;

      if (data.containsKey('epg_listings')) {
        final listings = data['epg_listings'] as List<dynamic>;
        return listings
            .map((e) => EpgModel.fromXtream(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get full EPG
  Future<List<EpgModel>> getFullEpg(ProviderModel provider) async {
    final url = provider.getXtreamUrl('get_simple_data_table&stream_id=all');

    try {
      final response = await _http.downloadJson(url!);
      final data = response as Map<String, dynamic>;

      if (data.containsKey('epg_listings')) {
        final listings = data['epg_listings'] as List<dynamic>;
        return listings
            .map((e) => EpgModel.fromXtream(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get EPG from XMLTV URL
  Future<List<EpgModel>> getXmlTvEpg(String url) async {
    try {
      final content = await _http.downloadString(url);
      return _parseXmlTvEpg(content);
    } catch (e) {
      return [];
    }
  }

  /// Parse XMLTV EPG format using proper XML parsing
  List<EpgModel> _parseXmlTvEpg(String content) {
    final epg = <EpgModel>[];
    
    try {
      final document = xml.XmlDocument.parse(content);
      final programmes = document.findAllElements('programme');
      
      for (final programme in programmes) {
        final start = programme.getAttribute('start');
        final stop = programme.getAttribute('stop');
        final channelId = programme.getAttribute('channel');
        
        if (start == null || stop == null || channelId == null) continue;
        
        final startTime = _parseXmlTvDate(start);
        final endTime = _parseXmlTvDate(stop);
        
        if (startTime == null || endTime == null) continue;
        
        // Get title element
        final titleElement = programme.findElements('title').firstOrNull;
        if (titleElement == null) continue;
        
        final title = titleElement.innerText;
        
        // Get optional description
        final descElement = programme.findElements('desc').firstOrNull;
        final description = descElement?.innerText;
        
        // Get optional category
        final categoryElement = programme.findElements('category').firstOrNull;
        final category = categoryElement?.innerText;
        
        // Get optional icon
        final iconElement = programme.findElements('icon').firstOrNull;
        final iconUrl = iconElement?.getAttribute('src');
        
        epg.add(
          EpgModel(
            id: '${channelId}_${startTime.millisecondsSinceEpoch}',
            channelId: channelId,
            title: title,
            startTime: startTime,
            endTime: endTime,
            description: description,
            category: category,
            iconUrl: iconUrl,
          ),
        );
      }
    } catch (e) {
      // If XML parsing fails, return empty list
      return [];
    }
    
    return epg;
  }

  DateTime? _parseXmlTvDate(String dateStr) {
    // XMLTV date format: 20210101120000 +0000
    try {
      final cleaned = dateStr.replaceAll(' ', '').substring(0, 14);
      return DateTime(
        int.parse(cleaned.substring(0, 4)),
        int.parse(cleaned.substring(4, 6)),
        int.parse(cleaned.substring(6, 8)),
        int.parse(cleaned.substring(8, 10)),
        int.parse(cleaned.substring(10, 12)),
        int.parse(cleaned.substring(12, 14)),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Xtream authentication result
class XtreamAuthResult {
  const XtreamAuthResult({
    required this.username,
    required this.status,
    this.expirationDate,
    this.maxConnections,
    this.activeConnections,
    this.serverUrl,
    this.serverPort,
    this.serverProtocol,
    this.timezone,
  });

  final String username;
  final String status;
  final DateTime? expirationDate;
  final int? maxConnections;
  final int? activeConnections;
  final String? serverUrl;
  final String? serverPort;
  final String? serverProtocol;
  final String? timezone;

  bool get isActive => status.toLowerCase() == 'active';
  bool get isExpired =>
      expirationDate != null && DateTime.now().isAfter(expirationDate!);
}

/// Xtream exception
class XtreamException implements Exception {
  const XtreamException(this.message);

  final String message;

  @override
  String toString() => message;
}
