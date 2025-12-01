import 'package:equatable/equatable.dart';

/// Represents a reminder for an EPG event
class ReminderModel extends Equatable {
  const ReminderModel({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.programTitle,
    required this.startTime,
    required this.endTime,
    this.channelLogoUrl,
    this.description,
    this.notificationId,
    this.reminderMinutesBefore = 5,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String channelId;
  final String channelName;
  final String programTitle;
  final DateTime startTime;
  final DateTime endTime;
  final String? channelLogoUrl;
  final String? description;
  final int? notificationId;
  final int reminderMinutesBefore;
  final bool isActive;
  final DateTime? createdAt;

  ReminderModel copyWith({
    String? id,
    String? channelId,
    String? channelName,
    String? programTitle,
    DateTime? startTime,
    DateTime? endTime,
    String? channelLogoUrl,
    String? description,
    int? notificationId,
    int? reminderMinutesBefore,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      ReminderModel(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        channelName: channelName ?? this.channelName,
        programTitle: programTitle ?? this.programTitle,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        channelLogoUrl: channelLogoUrl ?? this.channelLogoUrl,
        description: description ?? this.description,
        notificationId: notificationId ?? this.notificationId,
        reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'channelId': channelId,
        'channelName': channelName,
        'programTitle': programTitle,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'channelLogoUrl': channelLogoUrl,
        'description': description,
        'notificationId': notificationId,
        'reminderMinutesBefore': reminderMinutesBefore,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'] as String,
        channelId: json['channelId'] as String,
        channelName: json['channelName'] as String,
        programTitle: json['programTitle'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        channelLogoUrl: json['channelLogoUrl'] as String?,
        description: json['description'] as String?,
        notificationId: json['notificationId'] as int?,
        reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 5,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  /// Check if the program has already started
  bool get hasStarted => DateTime.now().isAfter(startTime);

  /// Check if the program has ended
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Check if the reminder is upcoming (not started yet)
  bool get isUpcoming => !hasStarted && isActive;

  /// Time until the program starts
  Duration get timeUntilStart => startTime.difference(DateTime.now());

  /// Formatted time until start (e.g., "2h 30m", "15m", "Starting soon")
  String get formattedTimeUntilStart {
    if (hasStarted) return 'Started';
    final duration = timeUntilStart;
    if (duration.inMinutes < 1) return 'Starting soon';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }

  /// Formatted start time (e.g., "14:30")
  String get formattedStartTime =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  /// Duration of the program
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  @override
  List<Object?> get props => [
        id,
        channelId,
        channelName,
        programTitle,
        startTime,
        endTime,
        channelLogoUrl,
        description,
        notificationId,
        reminderMinutesBefore,
        isActive,
        createdAt,
      ];
}
