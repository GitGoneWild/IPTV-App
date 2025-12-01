import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/core/services/m3u_parser_service.dart';

void main() {
  group('M3UParserService', () {
    const parser = M3UParserService();

    test('should parse valid M3U content', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-id="channel1" tvg-logo="http://logo.png" group-title="News",CNN
http://stream.example.com/cnn

#EXTINF:-1 tvg-id="channel2" tvg-logo="http://logo2.png" group-title="Sports",ESPN
http://stream.example.com/espn
''';

      final channels = parser.parse(content);

      expect(channels.length, equals(2));
      expect(channels[0].name, equals('CNN'));
      expect(channels[0].streamUrl, equals('http://stream.example.com/cnn'));
      expect(channels[0].logoUrl, equals('http://logo.png'));
      expect(channels[0].group, equals('News'));
      expect(channels[1].name, equals('ESPN'));
      expect(channels[1].group, equals('Sports'));
    });

    test('should validate valid M3U content', () {
      const validContent = '''
#EXTM3U
#EXTINF:-1,Channel 1
http://stream.example.com/1
''';

      expect(parser.validate(validContent), isTrue);
    });

    test('should reject invalid M3U content', () {
      const invalidContent = 'This is not a valid M3U file';

      expect(parser.validate(invalidContent), isFalse);
    });

    test('should extract groups from channels', () {
      const content = '''
#EXTM3U
#EXTINF:-1 group-title="News",CNN
http://stream1.com
#EXTINF:-1 group-title="Sports",ESPN
http://stream2.com
#EXTINF:-1 group-title="News",BBC
http://stream3.com
''';

      final channels = parser.parse(content);
      final groups = parser.extractGroups(channels);

      expect(groups.length, equals(2));
      expect(groups, contains('News'));
      expect(groups, contains('Sports'));
    });

    test('should handle empty content', () {
      const emptyContent = '';

      expect(parser.validate(emptyContent), isFalse);
      expect(parser.parse(emptyContent), isEmpty);
    });

    test('should handle content with only header', () {
      const headerOnly = '#EXTM3U\n';

      expect(parser.validate(headerOnly), isFalse);
    });

    test('should parse EXTINF attributes correctly', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-id="test-id" tvg-logo="http://logo.com/img.png" group-title="Test Group" catchup-days="7",Test Channel
http://stream.test.com/test
''';

      final channels = parser.parse(content);

      expect(channels.length, equals(1));
      expect(channels[0].name, equals('Test Channel'));
      expect(channels[0].epgId, equals('test-id'));
      expect(channels[0].logoUrl, equals('http://logo.com/img.png'));
      expect(channels[0].group, equals('Test Group'));
      expect(channels[0].catchupDays, equals(7));
    });
  });
}
