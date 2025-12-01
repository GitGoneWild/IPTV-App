import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'provider_model.g.dart';

/// IPTV provider type
@HiveType(typeId: 6)
enum ProviderType {
  @HiveField(0)
  m3u,

  @HiveField(1)
  xtream,
}

/// Represents an IPTV provider configuration
@HiveType(typeId: 7)
class ProviderModel extends Equatable {
  const ProviderModel({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.username,
    this.password,
    this.epgUrl,
    this.isActive = true,
    this.lastSync,
    this.expirationDate,
    this.maxConnections,
    this.createdAt,
    this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final ProviderType type;

  @HiveField(3)
  final String? url;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? epgUrl;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime? lastSync;

  @HiveField(9)
  final DateTime? expirationDate;

  @HiveField(10)
  final int? maxConnections;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  ProviderModel copyWith({
    String? id,
    String? name,
    ProviderType? type,
    String? url,
    String? username,
    String? password,
    String? epgUrl,
    bool? isActive,
    DateTime? lastSync,
    DateTime? expirationDate,
    int? maxConnections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProviderModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        url: url ?? this.url,
        username: username ?? this.username,
        password: password ?? this.password,
        epgUrl: epgUrl ?? this.epgUrl,
        isActive: isActive ?? this.isActive,
        lastSync: lastSync ?? this.lastSync,
        expirationDate: expirationDate ?? this.expirationDate,
        maxConnections: maxConnections ?? this.maxConnections,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Get the base URL for Xtream API calls
  String? get baseUrl {
    if (type != ProviderType.xtream || url == null) return null;
    final uri = Uri.tryParse(url!);
    if (uri == null) return null;
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  /// Get the full Xtream API URL with credentials
  String? getXtreamUrl(String action) {
    if (type != ProviderType.xtream) return null;
    return '$baseUrl/player_api.php?username=$username&password=$password&action=$action';
  }

  /// Get stream URL for Xtream live channels
  String? getLiveStreamUrl(String streamId, {String format = 'ts'}) {
    if (type != ProviderType.xtream) return null;
    return '$baseUrl/live/$username/$password/$streamId.$format';
  }

  /// Get stream URL for Xtream movies
  String? getMovieStreamUrl(String streamId, String extension) {
    if (type != ProviderType.xtream) return null;
    return '$baseUrl/movie/$username/$password/$streamId.$extension';
  }

  /// Get stream URL for Xtream series episodes
  String? getSeriesStreamUrl(String streamId, String extension) {
    if (type != ProviderType.xtream) return null;
    return '$baseUrl/series/$username/$password/$streamId.$extension';
  }

  /// Check if provider is expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Days until expiration
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'url': url,
        'username': username,
        'password': password,
        'epgUrl': epgUrl,
        'isActive': isActive,
        'lastSync': lastSync?.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'maxConnections': maxConnections,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ProviderType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ProviderType.m3u,
        ),
        url: json['url'] as String?,
        username: json['username'] as String?,
        password: json['password'] as String?,
        epgUrl: json['epgUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        lastSync: json['lastSync'] != null
            ? DateTime.parse(json['lastSync'] as String)
            : null,
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'] as String)
            : null,
        maxConnections: json['maxConnections'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        url,
        username,
        password,
        epgUrl,
        isActive,
        lastSync,
        expirationDate,
        maxConnections,
        createdAt,
        updatedAt,
      ];
}
