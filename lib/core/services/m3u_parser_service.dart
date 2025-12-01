import '../../data/models/channel_model.dart';
import 'package:uuid/uuid.dart';

/// Service for parsing M3U playlist files
class M3UParserService {
  const M3UParserService();

  static const _uuid = Uuid();

  /// Parse M3U playlist content into channels
  List<ChannelModel> parse(String content) {
    final channels = <ChannelModel>[];
    final lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    String? currentGroup;
    String? currentEpgId;
    int? currentCatchupDays;
    Map<String, dynamic>? currentMetadata;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        // Parse EXTINF line
        final info = _parseExtInf(line);
        currentName = info['name'];
        currentLogo = info['tvg-logo'];
        currentGroup = info['group-title'];
        currentEpgId = info['tvg-id'];
        currentCatchupDays = info['catchup-days'] != null
            ? int.tryParse(info['catchup-days']!)
            : null;
        currentMetadata = info;
      } else if (!line.startsWith('#')) {
        // This is the stream URL
        if (currentName != null) {
          channels.add(
            ChannelModel(
              id: _uuid.v4(),
              name: currentName,
              streamUrl: line,
              logoUrl: currentLogo,
              group: currentGroup,
              epgId: currentEpgId,
              catchupDays: currentCatchupDays,
              metadata: currentMetadata,
            ),
          );
        }

        // Reset for next entry
        currentName = null;
        currentLogo = null;
        currentGroup = null;
        currentEpgId = null;
        currentCatchupDays = null;
        currentMetadata = null;
      }
    }

    return channels;
  }

  /// Parse #EXTINF line attributes
  Map<String, String?> _parseExtInf(String line) {
    final result = <String, String?>{};

    // Remove #EXTINF: prefix
    var content = line.substring(8);

    // Find the comma that separates duration/attributes from channel name
    final commaIndex = content.lastIndexOf(',');
    if (commaIndex != -1) {
      result['name'] = content.substring(commaIndex + 1).trim();
      content = content.substring(0, commaIndex);
    }

    // Parse attributes
    final attributeRegex = RegExp(r'([\w-]+)="([^"]*)"');
    final matches = attributeRegex.allMatches(content);

    for (final match in matches) {
      final key = match.group(1)!.toLowerCase();
      final value = match.group(2);
      result[key] = value;
    }

    // Parse duration (the first value before any attributes)
    final durationMatch = RegExp(r'^-?\d+').firstMatch(content);
    if (durationMatch != null) {
      result['duration'] = durationMatch.group(0);
    }

    return result;
  }

  /// Validate M3U content
  bool validate(String content) {
    if (content.isEmpty) return false;

    // Check for #EXTM3U header (optional but common)
    final hasHeader = content.trim().startsWith('#EXTM3U');

    // Check for at least one #EXTINF entry
    final hasChannels = content.contains('#EXTINF:');

    // Check for at least one stream URL (non-comment, non-empty line)
    final lines = content.split('\n');
    final hasUrls = lines.any((line) {
      final trimmed = line.trim();
      return trimmed.isNotEmpty &&
          !trimmed.startsWith('#') &&
          (trimmed.startsWith('http://') ||
              trimmed.startsWith('https://') ||
              trimmed.startsWith('rtmp://') ||
              trimmed.startsWith('rtsp://'));
    });

    return (hasHeader || hasChannels) && hasUrls;
  }

  /// Extract unique groups from channels
  List<String> extractGroups(List<ChannelModel> channels) {
    final groups = <String>{};
    for (final channel in channels) {
      if (channel.group != null && channel.group!.isNotEmpty) {
        groups.add(channel.group!);
      }
    }
    return groups.toList()..sort();
  }
}
