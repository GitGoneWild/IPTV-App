import 'package:equatable/equatable.dart';

/// Represents a live TV channel
class ChannelModel extends Equatable {
  const ChannelModel({
    required this.id,
    required this.name,
    this.streamUrl,
    this.logoUrl,
    this.group,
    this.epgId,
    this.catchupDays,
    this.isFavorite = false,
    this.isLocked = false,
    this.order = 0,
    this.lastWatched,
    this.metadata,
  });

  final String id;
  final String name;
  final String? streamUrl;
  final String? logoUrl;
  final String? group;
  final String? epgId;
  final int? catchupDays;
  final bool isFavorite;
  final bool isLocked;
  final int order;
  final DateTime? lastWatched;
  final Map<String, dynamic>? metadata;

  ChannelModel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? group,
    String? epgId,
    int? catchupDays,
    bool? isFavorite,
    bool? isLocked,
    int? order,
    DateTime? lastWatched,
    Map<String, dynamic>? metadata,
  }) =>
      ChannelModel(
        id: id ?? this.id,
        name: name ?? this.name,
        streamUrl: streamUrl ?? this.streamUrl,
        logoUrl: logoUrl ?? this.logoUrl,
        group: group ?? this.group,
        epgId: epgId ?? this.epgId,
        catchupDays: catchupDays ?? this.catchupDays,
        isFavorite: isFavorite ?? this.isFavorite,
        isLocked: isLocked ?? this.isLocked,
        order: order ?? this.order,
        lastWatched: lastWatched ?? this.lastWatched,
        metadata: metadata ?? this.metadata,
      );

  factory ChannelModel.fromM3U({
    required String id,
    required String name,
    String? streamUrl,
    String? logoUrl,
    String? group,
    String? epgId,
    int? catchupDays,
  }) =>
      ChannelModel(
        id: id,
        name: name,
        streamUrl: streamUrl,
        logoUrl: logoUrl,
        group: group,
        epgId: epgId,
        catchupDays: catchupDays,
      );

  factory ChannelModel.fromXtream(Map<String, dynamic> json, String baseUrl) =>
      ChannelModel(
        id: json['stream_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        streamUrl:
            '$baseUrl/live/${json['stream_id']}.ts',
        logoUrl: json['stream_icon']?.toString(),
        group: json['category_id']?.toString(),
        epgId: json['epg_channel_id']?.toString(),
        catchupDays: json['tv_archive_duration'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'streamUrl': streamUrl,
        'logoUrl': logoUrl,
        'group': group,
        'epgId': epgId,
        'catchupDays': catchupDays,
        'isFavorite': isFavorite,
        'isLocked': isLocked,
        'order': order,
        'lastWatched': lastWatched?.toIso8601String(),
        'metadata': metadata,
      };

  factory ChannelModel.fromJson(Map<String, dynamic> json) => ChannelModel(
        id: json['id'] as String,
        name: json['name'] as String,
        streamUrl: json['streamUrl'] as String?,
        logoUrl: json['logoUrl'] as String?,
        group: json['group'] as String?,
        epgId: json['epgId'] as String?,
        catchupDays: json['catchupDays'] as int?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
        lastWatched: json['lastWatched'] != null
            ? DateTime.parse(json['lastWatched'] as String)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        streamUrl,
        logoUrl,
        group,
        epgId,
        catchupDays,
        isFavorite,
        isLocked,
        order,
        lastWatched,
        metadata,
      ];
}
