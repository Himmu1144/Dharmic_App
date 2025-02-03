import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/quote.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String morningTimeKey = 'morning_notification_time';
  static const String eveningTimeKey = 'evening_notification_time';
  BuildContext? context;

  // Constructor to receive context
  NotificationService({this.context});

  // Notification channels
  static const String quoteChannelId = 'quote_notifications';
  static const String quoteChannelName = 'Daily Quotes';
  static const String quoteChannelDescription = 'Daily inspirational quotes';

  // Notification IDs
  static const int morningNotificationId = 1;
  static const int eveningNotificationId = 2;

  Future<bool> requestPermissions() async {
    if (context == null) return false;

    if (Theme.of(context!).platform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        if (granted != true) return false;

        if (await _requiresExactAlarmPermission()) {
          await androidImplementation.requestExactAlarmsPermission();
          return await androidImplementation.canScheduleExactNotifications() ??
              false;
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _requiresExactAlarmPermission() async {
    if (context == null ||
        Theme.of(context!).platform != TargetPlatform.android) {
      return false;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 31; // Android 12 or higher
  }

  Future<void> initNotification() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings for both platforms
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notification permissions not granted');
    }
  }

  void onNotificationTap(NotificationResponse response) {
    // Parse the notification payload and navigate to the quote
    try {
      if (response.payload != null) {
        // Handle the navigation in your app
        debugPrint('Notification tapped with payload: ${response.payload}');
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  Future<void> scheduleQuoteNotifications(Quote quote,
      {int? morningHour, int? eveningHour}) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notifications permission not granted');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    morningHour ??= prefs.getInt(morningTimeKey) ?? 9;
    eveningHour ??= prefs.getInt(eveningTimeKey) ?? 18;

    await scheduleNotification(
      id: 1,
      title: "Daily Wisdom",
      body: quote.quote,
      payload: quote.id.toString(),
      hour: morningHour,
      minute: 0,
    );

    await scheduleNotification(
      id: 2,
      title: "Evening Reflection",
      body: quote.quote,
      payload: quote.id.toString(),
      hour: eveningHour,
      minute: 0,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int hour,
    required int minute,
  }) async {
    // ...existing scheduling code...
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'quote_channel',
            'Daily Quotes',
            channelDescription: 'Daily inspirational quotes',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      await _scheduleInexactNotification(id, title, body, payload);
    }
  }

  Future<void> _scheduleInexactNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    await notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quote_channel',
          'Daily Quotes',
          channelDescription: 'Daily inspirational quotes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> updateNotificationTimes(int morningHour, int eveningHour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(morningTimeKey, morningHour);
    await prefs.setInt(eveningTimeKey, eveningHour);

    // Cancel existing notifications and reschedule with new times
    await cancelAllNotifications();
    // You'll need to reschedule notifications with a new quote here
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  // Add this test method
  Future<void> showTestNotification() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notifications permission not granted');
      return;
    }

    await notificationsPlugin.show(
      999, // Test notification ID
      'Test Notification',
      'This is a test notification from Dharmic Quotes',
      NotificationDetails(
        android: AndroidNotificationDetails(
          quoteChannelId,
          quoteChannelName,
          channelDescription: quoteChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
