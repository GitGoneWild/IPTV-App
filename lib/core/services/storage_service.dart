import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/category_model.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/epg_model.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/series_model.dart';

/// Storage service for local data persistence
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  late FlutterSecureStorage _secureStorage;
  bool _initialized = false;

  // Box names
  static const String _providersBox = 'providers';
  static const String _profilesBox = 'profiles';
  static const String _channelsBox = 'channels';
  static const String _moviesBox = 'movies';
  static const String _seriesBox = 'series';
  static const String _categoriesBox = 'categories';
  static const String _epgBox = 'epg';
  static const String _settingsBox = 'settings';
  static const String _favoritesBox = 'favorites';
  static const String _watchHistoryBox = 'watch_history';

  // Settings keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyActiveProfileId = 'active_profile_id';
  static const String keyActiveProviderId = 'active_provider_id';
  static const String keyParentalPin = 'parental_pin';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyBufferSize = 'buffer_size';
  static const String keyVideoQuality = 'video_quality';

  /// Initialize storage
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);

    // Register adapters if not registered
    _registerAdapters();

    // Open boxes
    await Hive.openBox<String>(_providersBox);
    await Hive.openBox<String>(_profilesBox);
    await Hive.openBox<String>(_channelsBox);
    await Hive.openBox<String>(_moviesBox);
    await Hive.openBox<String>(_seriesBox);
    await Hive.openBox<String>(_categoriesBox);
    await Hive.openBox<String>(_epgBox);
    await Hive.openBox<dynamic>(_settingsBox);
    await Hive.openBox<String>(_favoritesBox);
    await Hive.openBox<String>(_watchHistoryBox);

    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    _initialized = true;
  }

  void _registerAdapters() {
    // We use JSON serialization instead of Hive adapters for flexibility
  }

  // Settings operations
  Box<dynamic> get _settings => Hive.box(_settingsBox);

  bool get isFirstLaunch => _settings.get(keyFirstLaunch, defaultValue: true) as bool;

  Future<void> setFirstLaunch(bool value) async {
    await _settings.put(keyFirstLaunch, value);
  }

  String? get activeProfileId => _settings.get(keyActiveProfileId) as String?;

  Future<void> setActiveProfileId(String? id) async {
    if (id == null) {
      await _settings.delete(keyActiveProfileId);
    } else {
      await _settings.put(keyActiveProfileId, id);
    }
  }

  String? get activeProviderId => _settings.get(keyActiveProviderId) as String?;

  Future<void> setActiveProviderId(String? id) async {
    if (id == null) {
      await _settings.delete(keyActiveProviderId);
    } else {
      await _settings.put(keyActiveProviderId, id);
    }
  }

  int get bufferSize => _settings.get(keyBufferSize, defaultValue: 5000) as int;

  Future<void> setBufferSize(int value) async {
    await _settings.put(keyBufferSize, value);
  }

  String get videoQuality =>
      _settings.get(keyVideoQuality, defaultValue: 'auto') as String;

  Future<void> setVideoQuality(String value) async {
    await _settings.put(keyVideoQuality, value);
  }

  // Secure storage for sensitive data
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async => _secureStorage.read(key: key);

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Providers operations
  Box<String> get _providers => Hive.box(_providersBox);

  Future<void> saveProvider(ProviderModel provider) async {
    await _providers.put(provider.id, json.encode(provider.toJson()));
    // Save credentials securely
    if (provider.password != null) {
      await saveSecure('provider_${provider.id}_password', provider.password!);
    }
  }

  Future<List<ProviderModel>> getProviders() async {
    final providers = <ProviderModel>[];
    for (final key in _providers.keys) {
      final data = _providers.get(key);
      if (data != null) {
        final provider = ProviderModel.fromJson(
          json.decode(data) as Map<String, dynamic>,
        );
        // Get password from secure storage
        final password = await getSecure('provider_${provider.id}_password');
        providers.add(provider.copyWith(password: password));
      }
    }
    return providers;
  }

  Future<ProviderModel?> getProvider(String id) async {
    final data = _providers.get(id);
    if (data == null) return null;
    final provider = ProviderModel.fromJson(
      json.decode(data) as Map<String, dynamic>,
    );
    final password = await getSecure('provider_${provider.id}_password');
    return provider.copyWith(password: password);
  }

  Future<void> deleteProvider(String id) async {
    await _providers.delete(id);
    await deleteSecure('provider_${id}_password');
  }

  // Profiles operations
  Box<String> get _profiles => Hive.box(_profilesBox);

  Future<void> saveProfile(ProfileModel profile) async {
    // Don't save PIN in regular storage
    final profileToSave = profile.copyWith(parentalPin: null);
    await _profiles.put(profile.id, json.encode(profileToSave.toJson()));
    // Save PIN securely
    if (profile.parentalPin != null) {
      await saveSecure('profile_${profile.id}_pin', profile.parentalPin!);
    }
  }

  Future<List<ProfileModel>> getProfiles() async {
    final profiles = <ProfileModel>[];
    for (final key in _profiles.keys) {
      final data = _profiles.get(key);
      if (data != null) {
        final profile = ProfileModel.fromJson(
          json.decode(data) as Map<String, dynamic>,
        );
        final pin = await getSecure('profile_${profile.id}_pin');
        profiles.add(profile.copyWith(parentalPin: pin));
      }
    }
    return profiles;
  }

  Future<ProfileModel?> getProfile(String id) async {
    final data = _profiles.get(id);
    if (data == null) return null;
    final profile = ProfileModel.fromJson(
      json.decode(data) as Map<String, dynamic>,
    );
    final pin = await getSecure('profile_${profile.id}_pin');
    return profile.copyWith(parentalPin: pin);
  }

  Future<void> deleteProfile(String id) async {
    await _profiles.delete(id);
    await deleteSecure('profile_${id}_pin');
  }

  // Channels operations
  Box<String> get _channels => Hive.box(_channelsBox);

  Future<void> saveChannels(List<ChannelModel> channels) async {
    await _channels.clear();
    for (final channel in channels) {
      await _channels.put(channel.id, json.encode(channel.toJson()));
    }
  }

  List<ChannelModel> getChannels() {
    final channels = <ChannelModel>[];
    for (final key in _channels.keys) {
      final data = _channels.get(key);
      if (data != null) {
        channels.add(
          ChannelModel.fromJson(json.decode(data) as Map<String, dynamic>),
        );
      }
    }
    return channels;
  }

  Future<void> updateChannel(ChannelModel channel) async {
    await _channels.put(channel.id, json.encode(channel.toJson()));
  }

  // Movies operations
  Box<String> get _movies => Hive.box(_moviesBox);

  Future<void> saveMovies(List<MovieModel> movies) async {
    await _movies.clear();
    for (final movie in movies) {
      await _movies.put(movie.id, json.encode(movie.toJson()));
    }
  }

  List<MovieModel> getMovies() {
    final movies = <MovieModel>[];
    for (final key in _movies.keys) {
      final data = _movies.get(key);
      if (data != null) {
        movies.add(
          MovieModel.fromJson(json.decode(data) as Map<String, dynamic>),
        );
      }
    }
    return movies;
  }

  Future<void> updateMovie(MovieModel movie) async {
    await _movies.put(movie.id, json.encode(movie.toJson()));
  }

  // Series operations
  Box<String> get _series => Hive.box(_seriesBox);

  Future<void> saveSeries(List<SeriesModel> series) async {
    await _series.clear();
    for (final s in series) {
      await _series.put(s.id, json.encode(s.toJson()));
    }
  }

  List<SeriesModel> getSeries() {
    final series = <SeriesModel>[];
    for (final key in _series.keys) {
      final data = _series.get(key);
      if (data != null) {
        series.add(
          SeriesModel.fromJson(json.decode(data) as Map<String, dynamic>),
        );
      }
    }
    return series;
  }

  Future<void> updateSeries(SeriesModel series) async {
    await _series.put(series.id, json.encode(series.toJson()));
  }

  // Categories operations
  Box<String> get _categories => Hive.box(_categoriesBox);

  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _categories.clear();
    for (final category in categories) {
      await _categories.put(category.id, json.encode(category.toJson()));
    }
  }

  List<CategoryModel> getCategories() {
    final categories = <CategoryModel>[];
    for (final key in _categories.keys) {
      final data = _categories.get(key);
      if (data != null) {
        categories.add(
          CategoryModel.fromJson(json.decode(data) as Map<String, dynamic>),
        );
      }
    }
    return categories;
  }

  // EPG operations
  Box<String> get _epg => Hive.box(_epgBox);

  Future<void> saveEpg(List<EpgModel> epgEntries) async {
    await _epg.clear();
    for (final entry in epgEntries) {
      await _epg.put(entry.id, json.encode(entry.toJson()));
    }
  }

  List<EpgModel> getEpg() {
    final epg = <EpgModel>[];
    for (final key in _epg.keys) {
      final data = _epg.get(key);
      if (data != null) {
        epg.add(EpgModel.fromJson(json.decode(data) as Map<String, dynamic>));
      }
    }
    return epg;
  }

  List<EpgModel> getEpgForChannel(String channelId) {
    final now = DateTime.now();
    return getEpg()
        .where((e) => e.channelId == channelId && e.endTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Favorites operations
  Box<String> get _favorites => Hive.box(_favoritesBox);

  Future<void> addFavorite(String type, String id) async {
    await _favorites.put('${type}_$id', id);
  }

  Future<void> removeFavorite(String type, String id) async {
    await _favorites.delete('${type}_$id');
  }

  bool isFavorite(String type, String id) =>
      _favorites.containsKey('${type}_$id');

  List<String> getFavoriteIds(String type) {
    final ids = <String>[];
    for (final key in _favorites.keys) {
      if (key.toString().startsWith('${type}_')) {
        final id = _favorites.get(key);
        if (id != null) ids.add(id);
      }
    }
    return ids;
  }

  // Watch history operations
  Box<String> get _watchHistory => Hive.box(_watchHistoryBox);

  Future<void> saveWatchProgress(
    String type,
    String id,
    Duration progress,
  ) async {
    final entry = {
      'type': type,
      'id': id,
      'progress': progress.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _watchHistory.put('${type}_$id', json.encode(entry));
  }

  Map<String, Duration> getWatchProgress() {
    final progress = <String, Duration>{};
    for (final key in _watchHistory.keys) {
      final data = _watchHistory.get(key);
      if (data != null) {
        final entry = json.decode(data) as Map<String, dynamic>;
        final id = entry['id'] as String;
        final type = entry['type'] as String;
        final progressMs = entry['progress'] as int;
        progress['${type}_$id'] = Duration(milliseconds: progressMs);
      }
    }
    return progress;
  }

  Duration? getWatchProgressForItem(String type, String id) {
    final data = _watchHistory.get('${type}_$id');
    if (data == null) return null;
    final entry = json.decode(data) as Map<String, dynamic>;
    return Duration(milliseconds: entry['progress'] as int);
  }

  List<Map<String, dynamic>> getRecentlyWatched({int limit = 20}) {
    final entries = <Map<String, dynamic>>[];
    for (final key in _watchHistory.keys) {
      final data = _watchHistory.get(key);
      if (data != null) {
        entries.add(json.decode(data) as Map<String, dynamic>);
      }
    }
    entries.sort((a, b) {
      final aTime = DateTime.parse(a['timestamp'] as String);
      final bTime = DateTime.parse(b['timestamp'] as String);
      return bTime.compareTo(aTime);
    });
    return entries.take(limit).toList();
  }

  // Clear all data
  Future<void> clearAll() async {
    await _providers.clear();
    await _profiles.clear();
    await _channels.clear();
    await _movies.clear();
    await _series.clear();
    await _categories.clear();
    await _epg.clear();
    await _settings.clear();
    await _favorites.clear();
    await _watchHistory.clear();
    await _secureStorage.deleteAll();
  }
}
