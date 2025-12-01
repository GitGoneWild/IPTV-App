import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'epg_model.g.dart';

/// Represents an EPG (Electronic Program Guide) entry
@HiveType(typeId: 5)
class EpgModel extends Equatable {
  const EpgModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.category,
    this.iconUrl,
    this.rating,
    this.isNew,
    this.isLive,
    this.isRepeat,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String channelId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final String? iconUrl;

  @HiveField(8)
  final String? rating;

  @HiveField(9)
  final bool? isNew;

  @HiveField(10)
  final bool? isLive;

  @HiveField(11)
  final bool? isRepeat;

  EpgModel copyWith({
    String? id,
    String? channelId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? category,
    String? iconUrl,
    String? rating,
    bool? isNew,
    bool? isLive,
    bool? isRepeat,
  }) =>
      EpgModel(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        description: description ?? this.description,
        category: category ?? this.category,
        iconUrl: iconUrl ?? this.iconUrl,
        rating: rating ?? this.rating,
        isNew: isNew ?? this.isNew,
        isLive: isLive ?? this.isLive,
        isRepeat: isRepeat ?? this.isRepeat,
      );

  factory EpgModel.fromXtream(Map<String, dynamic> json) {
    final start = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(json['start_timestamp']?.toString() ?? '0') ?? 0 * 1000,
    );
    final end = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(json['stop_timestamp']?.toString() ?? '0') ?? 0 * 1000,
    );
    return EpgModel(
      id: json['id']?.toString() ?? '',
      channelId: json['channel_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      startTime: start,
      endTime: end,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'channelId': channelId,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'description': description,
        'category': category,
        'iconUrl': iconUrl,
        'rating': rating,
        'isNew': isNew,
        'isLive': isLive,
        'isRepeat': isRepeat,
      };

  factory EpgModel.fromJson(Map<String, dynamic> json) => EpgModel(
        id: json['id'] as String,
        channelId: json['channelId'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        description: json['description'] as String?,
        category: json['category'] as String?,
        iconUrl: json['iconUrl'] as String?,
        rating: json['rating'] as String?,
        isNew: json['isNew'] as bool?,
        isLive: json['isLive'] as bool?,
        isRepeat: json['isRepeat'] as bool?,
      );

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Check if currently airing
  bool get isCurrentlyAiring {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if ended
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (!isCurrentlyAiring) {
      return hasEnded ? 1.0 : 0.0;
    }
    final total = endTime.difference(startTime).inSeconds;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return elapsed / total;
  }

  /// Time until start (negative if already started)
  Duration get timeUntilStart => startTime.difference(DateTime.now());

  /// Time until end
  Duration get timeUntilEnd => endTime.difference(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        channelId,
        title,
        startTime,
        endTime,
        description,
        category,
        iconUrl,
        rating,
        isNew,
        isLive,
        isRepeat,
      ];
}
