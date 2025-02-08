import 'package:dharmic/services/isar_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String MORNING_HOUR_KEY = 'morning_hour';
  static const String MORNING_MINUTE_KEY = 'morning_minute';
  static const String EVENING_HOUR_KEY = 'evening_hour';
  static const String EVENING_MINUTE_KEY = 'evening_minute';
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
    const InitializationSettings initializationSettings =
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

  Future<void> scheduleQuoteNotification({
    required TimeOfDay time,
    required bool enabled,
    bool isMorningTime = true, // to distinguish between morning/evening
  }) async {
    if (!enabled) {
      // Cancel notifications if disabled
      await cancelNotification(
          isMorningTime ? morningNotificationId : eveningNotificationId);
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Save the time
    if (isMorningTime) {
      await prefs.setInt(MORNING_HOUR_KEY, time.hour);
      await prefs.setInt(MORNING_MINUTE_KEY, time.minute);
    } else {
      await prefs.setInt(EVENING_HOUR_KEY, time.hour);
      await prefs.setInt(EVENING_MINUTE_KEY, time.minute);
    }

    // Get a random quote and schedule
    if (context != null) {
      final isarService = Provider.of<IsarService>(context!, listen: false);
      final quote = await isarService.getRandomUnreadQuote();
      if (quote != null) {
        await scheduleNotification(
          id: isMorningTime ? 1 : 2,
          title: isMorningTime ? "Morning Wisdom" : "Evening Reflection",
          body: quote.quote,
          payload: quote.id.toString(),
          hour: time.hour,
          minute: time.minute,
        );
      }
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

    // Get saved hours and minutes
    final mHour = morningHour ?? prefs.getInt(MORNING_HOUR_KEY) ?? 6;
    final mMinute = prefs.getInt(MORNING_MINUTE_KEY) ?? 0;
    final eHour = eveningHour ?? prefs.getInt(EVENING_HOUR_KEY) ?? 18;
    final eMinute = prefs.getInt(EVENING_MINUTE_KEY) ?? 0;

    // Schedule morning notification
    await scheduleNotification(
      id: morningNotificationId,
      title: "Morning Wisdom",
      body: quote.quote,
      payload: quote.id.toString(),
      hour: mHour,
      minute: mMinute,
    );

    // Schedule evening notification
    await scheduleNotification(
      id: eveningNotificationId,
      title: "Evening Reflection",
      body: quote.quote,
      payload: quote.id.toString(),
      hour: eHour,
      minute: eMinute,
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
      // await _scheduleInexactNotification(id, title, body, payload);
    }
  }

  // Future<void> _scheduleInexactNotification(
  //   int id,
  //   String title,
  //   String body,
  //   String payload,
  // ) async {
  //   await notificationsPlugin.periodicallyShow(
  //     id,
  //     title,
  //     body,
  //     RepeatInterval.daily,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'quote_channel',
  //         'Daily Quotes',
  //         channelDescription: 'Daily inspirational quotes',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  //     payload: payload,
  //   );
  // }

  // Future<void> updateNotificationTimes(int morningHour, int eveningHour) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt(MORNING_HOUR_KEY, morningHour);
  //   await prefs.setInt(EVENING_HOUR_KEY, eveningHour);

  //   // Cancel existing notifications and reschedule with new times
  //   await cancelAllNotifications();
  //   // You'll need to reschedule notifications with a new quote here
  // }

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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          quoteChannelId,
          quoteChannelName,
          channelDescription: quoteChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
