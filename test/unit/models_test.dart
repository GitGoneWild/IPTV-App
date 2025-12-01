import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/data/models/channel_model.dart';
import 'package:watchtheflix/data/models/movie_model.dart';
import 'package:watchtheflix/data/models/series_model.dart';
import 'package:watchtheflix/data/models/epg_model.dart';
import 'package:watchtheflix/data/models/provider_model.dart';
import 'package:watchtheflix/data/models/profile_model.dart';

void main() {
  group('ChannelModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'ch1',
        'name': 'Test Channel',
        'streamUrl': 'http://stream.test.com',
        'logoUrl': 'http://logo.test.com',
        'group': 'News',
        'epgId': 'test.epg',
        'isFavorite': true,
        'order': 1,
      };

      final channel = ChannelModel.fromJson(json);

      expect(channel.id, equals('ch1'));
      expect(channel.name, equals('Test Channel'));
      expect(channel.streamUrl, equals('http://stream.test.com'));
      expect(channel.logoUrl, equals('http://logo.test.com'));
      expect(channel.group, equals('News'));
      expect(channel.epgId, equals('test.epg'));
      expect(channel.isFavorite, isTrue);
      expect(channel.order, equals(1));
    });

    test('should convert to JSON', () {
      const channel = ChannelModel(
        id: 'ch1',
        name: 'Test Channel',
        streamUrl: 'http://stream.test.com',
        isFavorite: true,
      );

      final json = channel.toJson();

      expect(json['id'], equals('ch1'));
      expect(json['name'], equals('Test Channel'));
      expect(json['streamUrl'], equals('http://stream.test.com'));
      expect(json['isFavorite'], isTrue);
    });

    test('should create copy with updated values', () {
      const original = ChannelModel(
        id: 'ch1',
        name: 'Original',
        isFavorite: false,
      );

      final copy = original.copyWith(name: 'Updated', isFavorite: true);

      expect(copy.id, equals('ch1'));
      expect(copy.name, equals('Updated'));
      expect(copy.isFavorite, isTrue);
      expect(original.name, equals('Original'));
      expect(original.isFavorite, isFalse);
    });
  });

  group('MovieModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'mv1',
        'title': 'Test Movie',
        'year': 2023,
        'duration': 120,
        'rating': 8.5,
        'genres': ['Action', 'Drama'],
      };

      final movie = MovieModel.fromJson(json);

      expect(movie.id, equals('mv1'));
      expect(movie.title, equals('Test Movie'));
      expect(movie.year, equals(2023));
      expect(movie.duration, equals(120));
      expect(movie.rating, equals(8.5));
      expect(movie.genres, equals(['Action', 'Drama']));
    });

    test('should format duration correctly', () {
      const movie = MovieModel(
        id: 'mv1',
        title: 'Test',
        duration: 135,
      );

      expect(movie.durationString, equals('2h 15m'));
    });

    test('should format short duration correctly', () {
      const movie = MovieModel(
        id: 'mv1',
        title: 'Test',
        duration: 45,
      );

      expect(movie.durationString, equals('45m'));
    });

    test('should calculate watch progress percentage', () {
      const movie = MovieModel(
        id: 'mv1',
        title: 'Test',
        duration: 100,
        watchProgress: Duration(minutes: 50),
      );

      expect(movie.watchProgressPercent, equals(0.5));
    });
  });

  group('SeriesModel', () {
    test('should calculate total episodes', () {
      const series = SeriesModel(
        id: 'sr1',
        title: 'Test Series',
        seasons: [
          SeasonModel(
            id: 's1',
            seasonNumber: 1,
            episodes: [
              EpisodeModel(id: 'e1', episodeNumber: 1),
              EpisodeModel(id: 'e2', episodeNumber: 2),
            ],
          ),
          SeasonModel(
            id: 's2',
            seasonNumber: 2,
            episodes: [
              EpisodeModel(id: 'e3', episodeNumber: 1),
            ],
          ),
        ],
      );

      expect(series.totalSeasons, equals(2));
      expect(series.totalEpisodes, equals(3));
    });
  });

  group('EpgModel', () {
    test('should calculate progress correctly', () {
      final now = DateTime.now();
      final epg = EpgModel(
        id: 'epg1',
        channelId: 'ch1',
        title: 'Test Program',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
      );

      expect(epg.isCurrentlyAiring, isTrue);
      expect(epg.progress, closeTo(0.5, 0.05));
    });

    test('should detect ended program', () {
      final now = DateTime.now();
      final epg = EpgModel(
        id: 'epg1',
        channelId: 'ch1',
        title: 'Past Program',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );

      expect(epg.hasEnded, isTrue);
      expect(epg.isCurrentlyAiring, isFalse);
      expect(epg.progress, equals(1.0));
    });

    test('should detect future program', () {
      final now = DateTime.now();
      final epg = EpgModel(
        id: 'epg1',
        channelId: 'ch1',
        title: 'Future Program',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      );

      expect(epg.hasEnded, isFalse);
      expect(epg.isCurrentlyAiring, isFalse);
      expect(epg.progress, equals(0.0));
    });
  });

  group('ProviderModel', () {
    test('should generate correct Xtream URLs', () {
      const provider = ProviderModel(
        id: 'pv1',
        name: 'Test Provider',
        type: ProviderType.xtream,
        url: 'http://example.com:8080',
        username: 'user',
        password: 'pass',
      );

      expect(
        provider.getXtreamUrl('get_live_streams'),
        equals(
          'http://example.com:8080/player_api.php?username=user&password=pass&action=get_live_streams',
        ),
      );
      expect(
        provider.getLiveStreamUrl('123'),
        equals('http://example.com:8080/live/user/pass/123.ts'),
      );
      expect(
        provider.getMovieStreamUrl('456', 'mp4'),
        equals('http://example.com:8080/movie/user/pass/456.mp4'),
      );
    });

    test('should detect expired provider', () {
      final expiredProvider = ProviderModel(
        id: 'pv1',
        name: 'Expired Provider',
        type: ProviderType.xtream,
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(expiredProvider.isExpired, isTrue);
    });

    test('should calculate days until expiration', () {
      final provider = ProviderModel(
        id: 'pv1',
        name: 'Active Provider',
        type: ProviderType.xtream,
        expirationDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(provider.daysUntilExpiration, closeTo(30, 1));
    });
  });

  group('ProfileModel', () {
    test('should verify PIN correctly', () {
      const profile = ProfileModel(
        id: 'pr1',
        name: 'Test Profile',
        parentalPin: '1234',
      );

      expect(profile.hasParentalControls, isTrue);
      expect(profile.verifyPin('1234'), isTrue);
      expect(profile.verifyPin('0000'), isFalse);
    });

    test('should detect locked categories', () {
      const profile = ProfileModel(
        id: 'pr1',
        name: 'Test Profile',
        lockedCategories: ['adult', 'news'],
      );

      expect(profile.isCategoryLocked('adult'), isTrue);
      expect(profile.isCategoryLocked('sports'), isFalse);
    });
  });
}
