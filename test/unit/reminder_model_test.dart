import 'package:flutter_test/flutter_test.dart';
import 'package:watchtheflix/data/models/reminder_model.dart';

void main() {
  group('ReminderModel', () {
    test('should create from JSON', () {
      final now = DateTime.now();
      final startTime = now.add(const Duration(hours: 1));
      final endTime = now.add(const Duration(hours: 2));

      final json = {
        'id': 'rem1',
        'channelId': 'ch1',
        'channelName': 'Test Channel',
        'programTitle': 'Test Program',
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'channelLogoUrl': 'http://logo.test.com',
        'description': 'Test description',
        'notificationId': 12345,
        'reminderMinutesBefore': 10,
        'isActive': true,
        'createdAt': now.toIso8601String(),
      };

      final reminder = ReminderModel.fromJson(json);

      expect(reminder.id, equals('rem1'));
      expect(reminder.channelId, equals('ch1'));
      expect(reminder.channelName, equals('Test Channel'));
      expect(reminder.programTitle, equals('Test Program'));
      expect(reminder.channelLogoUrl, equals('http://logo.test.com'));
      expect(reminder.description, equals('Test description'));
      expect(reminder.notificationId, equals(12345));
      expect(reminder.reminderMinutesBefore, equals(10));
      expect(reminder.isActive, isTrue);
    });

    test('should convert to JSON', () {
      final now = DateTime.now();
      final startTime = now.add(const Duration(hours: 1));
      final endTime = now.add(const Duration(hours: 2));

      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test Channel',
        programTitle: 'Test Program',
        startTime: startTime,
        endTime: endTime,
        reminderMinutesBefore: 5,
        isActive: true,
        createdAt: now,
      );

      final json = reminder.toJson();

      expect(json['id'], equals('rem1'));
      expect(json['channelId'], equals('ch1'));
      expect(json['channelName'], equals('Test Channel'));
      expect(json['programTitle'], equals('Test Program'));
      expect(json['reminderMinutesBefore'], equals(5));
      expect(json['isActive'], isTrue);
    });

    test('should detect upcoming reminder', () {
      final now = DateTime.now();
      final startTime = now.add(const Duration(hours: 1));
      final endTime = now.add(const Duration(hours: 2));

      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test Channel',
        programTitle: 'Test Program',
        startTime: startTime,
        endTime: endTime,
        isActive: true,
      );

      expect(reminder.isUpcoming, isTrue);
      expect(reminder.hasStarted, isFalse);
      expect(reminder.hasEnded, isFalse);
    });

    test('should detect started program', () {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 30));
      final endTime = now.add(const Duration(minutes: 30));

      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test Channel',
        programTitle: 'Test Program',
        startTime: startTime,
        endTime: endTime,
        isActive: true,
      );

      expect(reminder.hasStarted, isTrue);
      expect(reminder.hasEnded, isFalse);
      expect(reminder.isUpcoming, isFalse);
    });

    test('should detect ended program', () {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(hours: 2));
      final endTime = now.subtract(const Duration(hours: 1));

      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test Channel',
        programTitle: 'Test Program',
        startTime: startTime,
        endTime: endTime,
        isActive: true,
      );

      expect(reminder.hasStarted, isTrue);
      expect(reminder.hasEnded, isTrue);
      expect(reminder.isUpcoming, isFalse);
    });

    test('should format time until start correctly', () {
      final now = DateTime.now();

      // Test minutes only
      final reminder1 = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test',
        programTitle: 'Test',
        startTime: now.add(const Duration(minutes: 45)),
        endTime: now.add(const Duration(minutes: 105)),
        isActive: true,
      );
      expect(reminder1.formattedTimeUntilStart, equals('45m'));

      // Test hours and minutes
      final reminder2 = ReminderModel(
        id: 'rem2',
        channelId: 'ch1',
        channelName: 'Test',
        programTitle: 'Test',
        startTime: now.add(const Duration(hours: 2, minutes: 30)),
        endTime: now.add(const Duration(hours: 3, minutes: 30)),
        isActive: true,
      );
      expect(reminder2.formattedTimeUntilStart, equals('2h 30m'));

      // Test hours only
      final reminder3 = ReminderModel(
        id: 'rem3',
        channelId: 'ch1',
        channelName: 'Test',
        programTitle: 'Test',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 4)),
        isActive: true,
      );
      expect(reminder3.formattedTimeUntilStart, equals('3h'));
    });

    test('should format start time correctly', () {
      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test',
        programTitle: 'Test',
        startTime: DateTime(2024, 1, 1, 14, 30),
        endTime: DateTime(2024, 1, 1, 15, 30),
        isActive: true,
      );

      expect(reminder.formattedStartTime, equals('14:30'));
    });

    test('should calculate duration correctly', () {
      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Test',
        programTitle: 'Test',
        startTime: DateTime(2024, 1, 1, 14, 0),
        endTime: DateTime(2024, 1, 1, 15, 30),
        isActive: true,
      );

      expect(reminder.durationMinutes, equals(90));
    });

    test('should create copy with updated values', () {
      final reminder = ReminderModel(
        id: 'rem1',
        channelId: 'ch1',
        channelName: 'Original',
        programTitle: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
      );

      final copy = reminder.copyWith(
        channelName: 'Updated',
        isActive: false,
      );

      expect(copy.id, equals('rem1'));
      expect(copy.channelName, equals('Updated'));
      expect(copy.isActive, isFalse);
      expect(reminder.channelName, equals('Original'));
      expect(reminder.isActive, isTrue);
    });
  });
}
