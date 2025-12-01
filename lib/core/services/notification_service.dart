import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for handling notifications
/// Prepared for Firebase Cloud Messaging integration
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const windowsSettings = WindowsInitializationSettings(
      appName: 'WatchTheFlix',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'watchtheflix_channel',
      'WatchTheFlix Notifications',
      channelDescription: 'Notifications from WatchTheFlix app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const windowsDetails = WindowsNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: windowsDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'watchtheflix_scheduled',
      'WatchTheFlix Scheduled Notifications',
      channelDescription: 'Scheduled notifications from WatchTheFlix app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const windowsDetails = WindowsNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: windowsDetails,
    );

    // Using zonedSchedule for proper timezone handling
    // For simplicity, using show with a delay check
    final now = DateTime.now();
    if (scheduledTime.isAfter(now)) {
      final delay = scheduledTime.difference(now);
      Future.delayed(delay, () async {
        await _localNotifications.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      });
    }
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to appropriate screen based on payload
    final payload = response.payload;
    if (payload != null) {
      // TODO: Implement navigation based on payload
      // Example: Navigate to a specific channel or movie
    }
  }

  // ============================================
  // Firebase Cloud Messaging Preparation
  // ============================================
  //
  // To enable FCM, add firebase_messaging package and configure:
  //
  // 1. Add to pubspec.yaml:
  //    firebase_core: ^latest
  //    firebase_messaging: ^latest
  //
  // 2. Configure Firebase project and add google-services.json (Android)
  //    and GoogleService-Info.plist (iOS)
  //
  // 3. Initialize Firebase in main.dart:
  //    await Firebase.initializeApp();
  //
  // 4. Uncomment and implement the following methods:
  //
  // Future<void> initializeFCM() async {
  //   final messaging = FirebaseMessaging.instance;
  //
  //   // Request permission
  //   final settings = await messaging.requestPermission();
  //
  //   // Get FCM token
  //   final token = await messaging.getToken();
  //   print('FCM Token: $token');
  //
  //   // Handle foreground messages
  //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  //
  //   // Handle background messages
  //   FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  //
  //   // Handle notification tap when app is in background
  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  // }
  //
  // void _handleForegroundMessage(RemoteMessage message) {
  //   final notification = message.notification;
  //   if (notification != null) {
  //     showNotification(
  //       id: message.hashCode,
  //       title: notification.title ?? '',
  //       body: notification.body ?? '',
  //       payload: message.data.toString(),
  //     );
  //   }
  // }
  //
  // static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  //   // Handle background message
  // }
  //
  // void _handleMessageOpenedApp(RemoteMessage message) {
  //   // Navigate based on message data
  // }
  //
  // Future<String?> getToken() async {
  //   return FirebaseMessaging.instance.getToken();
  // }
  //
  // Future<void> subscribeToTopic(String topic) async {
  //   await FirebaseMessaging.instance.subscribeToTopic(topic);
  // }
  //
  // Future<void> unsubscribeFromTopic(String topic) async {
  //   await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  // }
}
