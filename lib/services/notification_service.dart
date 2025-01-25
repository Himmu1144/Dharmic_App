// import 'package:dharmic/services/isar_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:isar/isar.dart';
// import 'dart:math';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final IsarService isarService = IsarService(); // Instance of IsarService

//   // Singleton pattern
//   static final NotificationService _instance = NotificationService._();
//   factory NotificationService() => _instance;
//   NotificationService._() {
//     _initializeNotifications();
//   }

//   Future<void> _initializeNotifications() async {
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         // Handle notification tap
//       },
//     );
//   }

//   Future<void> scheduleQuoteNotification({
//     required TimeOfDay time,
//     required bool enabled,
//   }) async {
//     if (!enabled) {
//       await cancelNotifications();
//       return;
//     }

//     // Get a random unread quote
//     final quotes = await isarService.getUnreadQuotes();
//     if (quotes.isEmpty) return;

//     final randomQuote = quotes[DateTime.now().millisecond % quotes.length];

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'daily_quotes',
//       'Daily Quotes',
//       channelDescription: 'Daily spiritual quotes notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Daily Quote',
//       randomQuote.quote,
//       _nextInstanceOfTime(time),
//       details,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   Future<void> showQuoteNotification() async {
//     // Get a random unread quote
//     final quotes = await isarService.getUnreadQuotes();
//     if (quotes.isEmpty) return;

//     // Fix random quote selection
//     final random = Random();
//     final randomQuote = quotes[random.nextInt(quotes.length)];

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'daily_quotes',
//       'Daily Quotes',
//       channelDescription: 'Daily spiritual quotes notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const NotificationDetails details =
//         NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Daily Quote',
//       randomQuote.quote,
//       details,
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }

//   Future<void> cancelNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
// }

// // Add to your settings page or a new notifications settings page
// class NotificationSettingsSection extends StatefulWidget {
//   final NotificationService notificationService;

//   const NotificationSettingsSection(
//       {Key? key, required this.notificationService})
//       : super(key: key);

//   @override
//   _NotificationSettingsState createState() => _NotificationSettingsState();
// }

// class _NotificationSettingsState extends State<NotificationSettingsSection> {
//   bool _isNotificationEnabled = false;
//   TimeOfDay _selectedTime1 = const TimeOfDay(hour: 6, minute: 0);
//   TimeOfDay _selectedTime2 = const TimeOfDay(hour: 18, minute: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SwitchListTile(
//           title: const Text('Enable Daily Quotes'),
//           value: _isNotificationEnabled,
//           onChanged: (bool value) {
//             setState(() {
//               _isNotificationEnabled = value;
//               _updateNotificationSchedule();
//             });
//           },
//         ),
//         if (_isNotificationEnabled) ...[
//           _buildTimePicker('First Notification Time', _selectedTime1,
//               (TimeOfDay newTime) {
//             setState(() {
//               _selectedTime1 = newTime;
//               _updateNotificationSchedule();
//             });
//           }),
//           _buildTimePicker('Second Notification Time', _selectedTime2,
//               (TimeOfDay newTime) {
//             setState(() {
//               _selectedTime2 = newTime;
//               _updateNotificationSchedule();
//             });
//           }),
//         ]
//       ],
//     );
//   }

//   Widget _buildTimePicker(String title, TimeOfDay currentTime,
//       void Function(TimeOfDay) onTimeChanged) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(currentTime.format(context)),
//       onTap: () async {
//         final pickedTime = await showTimePicker(
//           context: context,
//           initialTime: currentTime,
//         );
//         if (pickedTime != null) {
//           onTimeChanged(pickedTime);
//         }
//       },
//     );
//   }

//   void _updateNotificationSchedule() {
//     widget.notificationService.scheduleQuoteNotification(
//         time: _selectedTime1, enabled: _isNotificationEnabled);
//     widget.notificationService.scheduleQuoteNotification(
//         time: _selectedTime2, enabled: _isNotificationEnabled);
//   }
// }
