import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/epg_model.dart';
import '../../data/models/reminder_model.dart';
import 'notification_service.dart';

/// Service for managing EPG reminders
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const String _remindersBox = 'reminders';
  bool _initialized = false;
  final _uuid = const Uuid();

  /// Initialize the reminder service
  Future<void> initialize() async {
    if (_initialized) return;

    // Ensure the box is open
    if (!Hive.isBoxOpen(_remindersBox)) {
      await Hive.openBox<String>(_remindersBox);
    }

    _initialized = true;

    // Clean up expired reminders on initialization
    await _cleanupExpiredReminders();
  }

  Box<String> get _box => Hive.box(_remindersBox);

  /// Add a reminder for an EPG event
  Future<ReminderModel> addReminder({
    required String channelId,
    required String channelName,
    required EpgModel epgEvent,
    String? channelLogoUrl,
    int reminderMinutesBefore = 5,
  }) async {
    final id = _uuid.v4();
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    final reminder = ReminderModel(
      id: id,
      channelId: channelId,
      channelName: channelName,
      programTitle: epgEvent.title,
      startTime: epgEvent.startTime,
      endTime: epgEvent.endTime,
      channelLogoUrl: channelLogoUrl,
      description: epgEvent.description,
      notificationId: notificationId,
      reminderMinutesBefore: reminderMinutesBefore,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // Save reminder
    await _box.put(id, json.encode(reminder.toJson()));

    // Schedule notification
    await _scheduleNotification(reminder);

    return reminder;
  }

  /// Remove a reminder
  Future<void> removeReminder(String reminderId) async {
    final reminder = getReminder(reminderId);
    if (reminder != null && reminder.notificationId != null) {
      await NotificationService.instance.cancelNotification(reminder.notificationId!);
    }
    await _box.delete(reminderId);
  }

  /// Get a specific reminder
  ReminderModel? getReminder(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return ReminderModel.fromJson(json.decode(data) as Map<String, dynamic>);
  }

  /// Get all reminders
  List<ReminderModel> getAllReminders() {
    final reminders = <ReminderModel>[];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        reminders.add(
          ReminderModel.fromJson(json.decode(data) as Map<String, dynamic>),
        );
      }
    }
    return reminders;
  }

  /// Get upcoming reminders (sorted by start time)
  List<ReminderModel> getUpcomingReminders() {
    final reminders = getAllReminders()
        .where((r) => r.isUpcoming)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return reminders;
  }

  /// Check if a reminder exists for an EPG event
  bool hasReminder(String channelId, DateTime startTime) {
    final reminders = getAllReminders();
    return reminders.any(
      (r) =>
          r.channelId == channelId &&
          r.startTime.isAtSameMomentAs(startTime) &&
          r.isActive,
    );
  }

  /// Get reminder for a specific EPG event
  ReminderModel? getReminderForEvent(String channelId, DateTime startTime) {
    final reminders = getAllReminders();
    final matches = reminders.where(
      (r) =>
          r.channelId == channelId &&
          r.startTime.isAtSameMomentAs(startTime) &&
          r.isActive,
    );
    return matches.isEmpty ? null : matches.first;
  }

  /// Clear all reminders
  Future<void> clearAllReminders() async {
    // Cancel all notifications
    final reminders = getAllReminders();
    for (final reminder in reminders) {
      if (reminder.notificationId != null) {
        await NotificationService.instance.cancelNotification(reminder.notificationId!);
      }
    }
    await _box.clear();
  }

  /// Schedule notification for a reminder
  Future<void> _scheduleNotification(ReminderModel reminder) async {
    if (reminder.notificationId == null) return;

    final notifyTime = reminder.startTime.subtract(
      Duration(minutes: reminder.reminderMinutesBefore),
    );

    // Only schedule if the notification time is in the future
    if (notifyTime.isAfter(DateTime.now())) {
      try {
        await NotificationService.instance.scheduleNotification(
          id: reminder.notificationId!,
          title: '${reminder.channelName} - Starting Soon',
          body: '${reminder.programTitle} starts in ${reminder.reminderMinutesBefore} minutes',
          scheduledTime: notifyTime,
          payload: json.encode({
            'type': 'reminder',
            'channelId': reminder.channelId,
            'reminderId': reminder.id,
          }),
        );
      } catch (e) {
        debugPrint('Failed to schedule notification: $e');
      }
    }
  }

  /// Clean up expired reminders
  Future<void> _cleanupExpiredReminders() async {
    final reminders = getAllReminders();
    final now = DateTime.now();
    
    for (final reminder in reminders) {
      if (reminder.endTime.isBefore(now)) {
        await _box.delete(reminder.id);
      }
    }
  }
}
