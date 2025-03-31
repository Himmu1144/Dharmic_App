import 'dart:io';
import 'dart:typed_data';

import 'package:dharmic/main.dart';
import 'package:dharmic/pages/home_page.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Add at the top of the file before the class definition
NotificationService? _instance;

class NotificationService {
  // Add this static getter
  static NotificationService get instance {
    _instance ??= NotificationService();
    return _instance!;
  }

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

  // Add this helper method at an appropriate location in your NotificationService class
  Future<T?> _executeNotificationOperation<T>(
    Future<T> Function() operation,
    String operationName, {
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      // Log error
      debugPrint('Notification error in $operationName: $e');
      debugPrint(stackTrace.toString());

      // Could integrate with ErrorHandlingService later
      // ErrorHandlingService.instance.logError(operationName, e, stackTrace);

      return defaultValue;
    }
  }

  Future<String> _createCircularImage(String imagePath) async {
    return (await _executeNotificationOperation<String>(() async {
          // Read the image file
          final File imageFile = File(imagePath);
          final List<int> imageBytes = await imageFile.readAsBytes();
          final img.Image? originalImage =
              img.decodeImage(Uint8List.fromList(imageBytes));

          if (originalImage == null) {
            return imagePath; // Return original if decoding fails
          }

          // Create a square image with transparent background
          final int width = originalImage.width;
          final int height = originalImage.height;
          final int size = min(width, height);

          // Create destination image with circular mask
          final img.Image circularImage = img.Image(width: size, height: size);

          // Calculate center points
          final int centerX = (width - size) ~/ 2;
          final int centerY = (height - size) ~/ 2;

          // Create circular mask
          for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
              final int sourceX = x + centerX;
              final int sourceY = y + centerY;

              // Check if the point is within the circle
              final double distance =
                  sqrt(pow(x - size / 2, 2) + pow(y - size / 2, 2));
              if (distance <= size / 2 &&
                  sourceX >= 0 &&
                  sourceX < width &&
                  sourceY >= 0 &&
                  sourceY < height) {
                // Copy the pixel from original image
                circularImage.setPixel(
                    x, y, originalImage.getPixel(sourceX, sourceY));
              }
            }
          }

          // Save the circular image to a temporary file
          final Directory tempDir = await getTemporaryDirectory();
          final String circularImagePath =
              '${tempDir.path}/circular_${path.basename(imagePath)}';
          final File circularFile = File(circularImagePath);
          await circularFile.writeAsBytes(img.encodePng(circularImage));

          return circularImagePath;
        }, 'createCircularImage', defaultValue: imagePath)) ??
        imagePath;
  }

  Future<bool> requestPermissions() async {
    return await _executeNotificationOperation<bool>(() async {
          if (context == null) return false;

          if (Theme.of(context!).platform == TargetPlatform.android) {
            final AndroidFlutterLocalNotificationsPlugin?
                androidImplementation =
                notificationsPlugin.resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

            if (androidImplementation != null) {
              final bool? granted =
                  await androidImplementation.requestNotificationsPermission();
              if (granted != true) return false;

              return granted ?? false;
            }
          }
          return false;
        }, 'requestPermissions', defaultValue: false) ??
        false;
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

  void onNotificationTap(NotificationResponse response) async {
    try {
      if (response.payload != null) {
        debugPrint('Notification tapped with payload: ${response.payload}');

        // Parse the quote ID from payload
        final quoteId = int.tryParse(response.payload!);
        if (quoteId != null) {
          // Create a function to handle navigation to the home page
          _navigateToQuote(quoteId);
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  void _navigateToQuote(int quoteId) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Get the quote from Isar
    final isarService = Provider.of<IsarService>(context, listen: false);
    final quote = await isarService.getQuoteById(quoteId);

    if (quote == null) return;

    // Navigate to home if not already there
    if (ModalRoute.of(context)?.settings.name != '/home') {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/home', (route) => false);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Complete one transaction before starting another
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Find the home page state
      final homeState = findHomePageState(context);
      if (homeState != null) {
        // Navigate to the quote without any database operations
        (homeState as dynamic).navigateToQuoteIndex(quote);

        // After navigation completes, then mark as read in a separate transaction
        await Future.delayed(const Duration(milliseconds: 500));
        isarService.markQuoteAsRead(quote);
      }
    });
  }

// Add this helper method to find HomePage state
  State<HomePage>? findHomePageState(BuildContext context) {
    State<HomePage>? homeState;

    // Find HomePage state in widget tree
    void visitor(Element element) {
      if (element.widget is HomePage) {
        final state = (element as StatefulElement).state;
        if (state is State<HomePage>) {
          homeState = state;
        }
      } else {
        element.visitChildren(visitor);
      }
    }

    (context as Element).visitChildren(visitor);
    return homeState;
  }

  Future<void> scheduleQuoteNotification({
    required TimeOfDay time,
    required bool enabled,
    bool isMorningTime = true,
  }) async {
    if (!enabled) {
      await cancelNotification(
          isMorningTime ? morningNotificationId : eveningNotificationId);
      return;
    }

    // print(
    //     "Scheduling ${isMorningTime ? 'morning' : 'evening'} notification for ${context != null ? time.format(context!) : 'unknown time'}");

    final prefs = await SharedPreferences.getInstance();

    // Save both hour and minute
    if (isMorningTime) {
      await prefs.setInt(MORNING_HOUR_KEY, time.hour);
      await prefs.setInt(MORNING_MINUTE_KEY, time.minute);
      // print("Saved morning time: ${time.hour}:${time.minute}");
    } else {
      await prefs.setInt(EVENING_HOUR_KEY, time.hour);
      await prefs.setInt(EVENING_MINUTE_KEY, time.minute);
      // print("Saved evening time: ${time.hour}:${time.minute}");
    }

    // Schedule with new time
    if (context != null) {
      final isarService = Provider.of<IsarService>(context!, listen: false);
      final quote = await isarService.getRandomUnreadQuote();
      if (quote != null) {
        try {
          // Get author name
          final authorName = quote.author.value?.name ?? 'Unknown';
          // Extract asset to a file path that can be used by notifications
          String? filePath;
          if (quote.authorImg.isNotEmpty) {
            try {
              final tempDir = await getTemporaryDirectory();
              // Create a filename based on the author name to avoid conflicts
              final authorName = quote.author.value?.name ?? 'unknown';
              final tempPath =
                  '${tempDir.path}/${authorName.replaceAll(' ', '_')}.png';

              // Extract the asset to a temporary file
              final ByteData data = await rootBundle.load(quote.authorImg);
              final bytes = data.buffer.asUint8List();
              final File tempFile = File(tempPath);
              await tempFile.writeAsBytes(bytes);

              filePath = tempPath;
              // With this:
              filePath = await _createCircularImage(tempPath);
              // print(
              //     "Created circular temporary file for author image at: $filePath");
              // print("Created temporary file for author image at: $filePath");
            } catch (e) {
              // print("Error extracting asset to file: $e");
            }
          }

          await scheduleNotification(
            id: isMorningTime ? morningNotificationId : eveningNotificationId,
            title: isMorningTime ? "Morning Wisdom" : "Evening Wisdom",
            body: quote.quote,
            authorName: authorName,
            payload: quote.id.toString(),
            hour: time.hour,
            minute: time.minute,
            authorImagePath: filePath, // Pass the author image path
          );
          // print("Successfully scheduled notification");
        } catch (e) {
          // print("Error scheduling notification: $e");
        }
      }
    }
  }

  // Add a helper method to get the image path
  // Future<String?> _getAuthorImagePath(String author) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final imagePath = '${directory.path}/author_images/$author.png';
  //     final file = File(imagePath);

  //     if (await file.exists()) {
  //       return file.path;
  //     }

  //     // If specific author image doesn't exist, try to use an image from assets
  //     return 'assets/images/$author.png';
  //   } catch (e) {
  //     print('Error getting author image: $e');
  //     return null;
  //   }
  // }

  Future<void> cleanupTemporaryFiles() async {
    await _executeNotificationOperation(() async {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      final now = DateTime.now();
      for (var file in files) {
        if (file is File && file.path.contains('.png')) {
          final stat = await file.stat();
          // Delete files older than 7 days
          if (now.difference(stat.modified).inDays > 7) {
            await file.delete();
          }
        }
      }
    }, 'cleanupTemporaryFiles');
  }

  Future<bool> scheduleQuoteNotifications(Quote quote,
      {int? morningHour, int? eveningHour}) async {
    bool success = false;
    String errorMessage = 'Failed to schedule notifications';

    final result = await _executeNotificationOperation(() async {
      try {
        // Check permissions first
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          errorMessage = 'Notification permissions not granted';
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        final authorName = quote.author.value?.name ?? 'Unknown';

        // Get both hours and minutes
        final mHour = morningHour ?? prefs.getInt(MORNING_HOUR_KEY) ?? 6;
        final mMinute = prefs.getInt(MORNING_MINUTE_KEY) ?? 0;
        final eHour = eveningHour ?? prefs.getInt(EVENING_HOUR_KEY) ?? 18;
        final eMinute = prefs.getInt(EVENING_MINUTE_KEY) ?? 0;

        // Schedule both notifications with individual try-catch blocks
        try {
          await scheduleNotification(
            id: morningNotificationId,
            title: "Morning Wisdom",
            body: quote.quote,
            authorName: authorName,
            payload: quote.id.toString(),
            hour: mHour,
            minute: mMinute,
          );
        } catch (e) {
          debugPrint('Failed to schedule morning notification: $e');
          // Continue to try scheduling evening notification
        }

        try {
          await scheduleNotification(
            id: eveningNotificationId,
            title: "Evening Reflection",
            body: quote.quote,
            authorName: authorName,
            payload: quote.id.toString(),
            hour: eHour,
            minute: eMinute,
          );
        } catch (e) {
          debugPrint('Failed to schedule evening notification: $e');
        }

        return true;
      } catch (e, stackTrace) {
        errorMessage = 'Error: ${e.toString().split('\n')[0]}';
        debugPrint('Error in scheduleQuoteNotifications: $e');
        debugPrint(stackTrace.toString());
        return false;
      }
    }, 'scheduleQuoteNotifications', defaultValue: false);

    // Show error if the operation failed and context is available
    success = result ?? false;
    if (!success && context != null && context!.mounted) {
      // Use a post-frame callback to ensure we're not in the middle of a build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    return success;
  }

  // Future<void> scheduleQuoteNotifications(Quote quote,
  //     {int? morningHour, int? eveningHour}) async {

  //   await _executeNotificationOperation(() async {
  //     final hasPermission = await requestPermissions();
  //     if (!hasPermission) return;

  //     final prefs = await SharedPreferences.getInstance();
  //     final authorName = quote.author.value?.name ?? 'Unknown';

  //     // Get both hours and minutes
  //     final mHour = morningHour ?? prefs.getInt(MORNING_HOUR_KEY) ?? 6;
  //     final mMinute = prefs.getInt(MORNING_MINUTE_KEY) ?? 0;
  //     final eHour = eveningHour ?? prefs.getInt(EVENING_HOUR_KEY) ?? 18;
  //     final eMinute = prefs.getInt(EVENING_MINUTE_KEY) ?? 0;

  //     // Schedule both notifications
  //     await scheduleNotification(
  //       id: morningNotificationId,
  //       title: "Morning Wisdom",
  //       body: quote.quote,
  //       authorName: authorName,
  //       payload: quote.id.toString(),
  //       hour: mHour,
  //       minute: mMinute,
  //     );

  //     await scheduleNotification(
  //       id: eveningNotificationId,
  //       title: "Evening Reflection",
  //       body: quote.quote,
  //       authorName: authorName,
  //       payload: quote.id.toString(),
  //       hour: eHour,
  //       minute: eMinute,
  //     );
  //   }, 'scheduleQuoteNotifications');
  // }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? authorImagePath,
    String? payload,
    String? authorName,
  }) async {
    try {
      // Create notification time (for tomorrow to ensure it triggers)
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      final effectiveDate = scheduledDate.isBefore(now)
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;

      // Use androidScheduleMode.inexactAllowWhileIdle instead of exact
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(effectiveDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            quoteChannelId,
            quoteChannelName,
            channelDescription: quoteChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // Use inexact instead of exact
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Notification scheduled for ${hour}:${minute} (inexact mode)');
    } catch (e, stackTrace) {
      debugPrint('Error scheduling notification: $e\n$stackTrace');
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
    await _executeNotificationOperation(() async {
      // Directly use the plugin instance to cancel all notifications
      await notificationsPlugin.cancelAll();

      // Open system settings to disable notifications (if needed)
      final androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }, 'cancelAllNotifications');
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> showTestNotification() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notifications permission not granted');
      return;
    }

    try {
      // Use an image from your assets
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/buddha.png';

      // Extract the asset to a temporary file
      final ByteData data = await rootBundle.load('assets/images/buddha.png');
      final bytes = data.buffer.asUint8List();
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      // Create circular image
      final circularPath = await _createCircularImage(tempPath);

      // Message with author
      const String message =
          'This is a test notification from Dharmic Quotes with an author image.';
      const String fullMessage = '$message\n\n~ Buddha';

      await notificationsPlugin.show(
        999, // Test notification ID
        'Test Notification',
        fullMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            quoteChannelId,
            quoteChannelName,
            channelDescription: quoteChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            largeIcon: FilePathAndroidBitmap(circularPath),
            styleInformation: const BigTextStyleInformation(fullMessage),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
      // Fallback notification code...
    }
  }

  // Future<bool> _checkAndRequestExactAlarmPermission() async {
  //   if (Platform.isAndroid) {
  //     try {
  //       // Get Android implementation
  //       final androidImplementation =
  //           notificationsPlugin.resolvePlatformSpecificImplementation<
  //               AndroidFlutterLocalNotificationsPlugin>();

  //       if (androidImplementation == null) return false;

  //       // Check if we can schedule exact notifications
  //       final canScheduleExact =
  //           await androidImplementation.canScheduleExactNotifications() ??
  //               false;

  //       if (canScheduleExact) return true;

  //       // For Android 12+ we should redirect users to settings
  //       final deviceInfo = await DeviceInfoPlugin().androidInfo;
  //       if (deviceInfo.version.sdkInt >= 31) {
  //         // Android 12+
  //         if (context != null && context!.mounted) {
  //           final bool? result = await showDialog<bool>(
  //             context: context!,
  //             builder: (BuildContext context) => AlertDialog(
  //               title: const Text('Permissions Required'),
  //               content: const Text(
  //                   'Scheduled notifications require "Exact Alarm" permission. Please enable it in settings.'),
  //               actions: [
  //                 TextButton(
  //                   child: const Text('Cancel'),
  //                   onPressed: () => Navigator.pop(context, false),
  //                 ),
  //                 TextButton(
  //                   child: const Text('Open Settings'),
  //                   onPressed: () {
  //                     // Use appropriate method based on the app_settings package version
  //                     AppSettings.openAppSettings(
  //                       type: AppSettingsType.alarm,
  //                     );
  //                     Navigator.pop(context, true);
  //                   },
  //                 ),
  //               ],
  //             ),
  //           );
  //           return result ?? false;
  //         }
  //       }
  //       return false;
  //     } catch (e) {
  //       debugPrint('Error checking exact alarm permission: $e');
  //       return false;
  //     }
  //   }
  //   return true; // Not Android, so no need for this permission
  // }

  Future<void> showSimpleTestNotification() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('Notifications permission not granted');
        return;
      }

      await notificationsPlugin.show(
        999,
        'Simple Test Notification',
        'This is a plain test notification without images',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            quoteChannelId,
            quoteChannelName,
            channelDescription: quoteChannelDescription,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Error showing simple test notification: $e');
      // Show error to user if context is available
      if (context != null && context!.mounted) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().split('\n')[0]}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
