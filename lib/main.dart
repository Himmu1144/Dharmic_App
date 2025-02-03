import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dharmic/pages/author_page.dart';
import 'package:dharmic/pages/bookmarks_page.dart';
import 'package:dharmic/pages/home_page.dart';
import 'package:dharmic/pages/search_page.dart';
import 'package:dharmic/pages/settings_page.dart';
import 'package:dharmic/services/notification_service.dart';
import 'package:dharmic/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  // Initialize data
  await isarService.loadAuthorsFromJson();
  await isarService.loadQuotesWithAuthors();

  await AndroidAlarmManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => isarService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/settings': (context) => const SettingsPage(), // Define the route here
        '/searchpage': (context) => const SearchPage(), // Define the route here
        '/author': (context) => const AuthorPage(),
        '/bookmarks': (context) =>
            const BookmarksPage(), // Define the route here
        // Define the route here
      },
    );
  }
}
