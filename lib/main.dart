import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dharmic/models/author.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/pages/author_page.dart';
import 'package:dharmic/pages/bookmarks_page.dart';
import 'package:dharmic/pages/home_page.dart';
import 'package:dharmic/pages/language_selection_screen.dart';
import 'package:dharmic/pages/search_page.dart';
import 'package:dharmic/pages/settings_page.dart';
import 'package:dharmic/pages/splash_screen.dart';
import 'package:dharmic/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';
import 'models/app_settings.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [AuthorSchema, QuoteSchema, AppSettingsSchema],
    directory: dir.path,
    inspector: true,
  );

  final isarService = IsarService(isar);
  await isarService.loadAuthorsFromJson();
  await isarService.loadQuotesWithAuthors();

  try {
    await AndroidAlarmManager.initialize();
  } catch (e) {
    print('Warning: Failed to initialize Android Alarm Manager: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: isarService),
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
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/language': (context) => const LanguageSelectionScreen(),
        '/settings': (context) => const SettingsPage(),
        '/search': (context) => const SearchPage(),
        '/author': (context) => const AuthorPage(),
        '/bookmarks': (context) => const BookmarksPage(),
      },
    );
  }
}
