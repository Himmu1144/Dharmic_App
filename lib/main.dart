import 'dart:async';
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
import 'package:dharmic/services/error_handling_service.dart'; // Add this import
import 'package:dharmic/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';
import 'models/app_settings.dart';
import 'package:path_provider/path_provider.dart';

// Add this near the top of main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Add this line
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red.withOpacity(0.1),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 32),
              const SizedBox(height: 8),
              const Text('An error occurred in this section'),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(navigatorKey.currentContext!).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Wrap everything in runZonedGuarded for catching errors outside Flutter
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); // Show error in console

      // Log error to our service
      ErrorHandlingService.instance
          .logError('Flutter Framework', details.exception, details.stack);

      // Show UI error if in debug mode or if we have a valid context
      if (navigatorKey.currentContext != null) {
        ErrorHandlingService.instance.showErrorToUser(
          navigatorKey.currentContext!,
          'An error occurred in the app',
          fatal:
              ErrorHandlingService.instance.isCriticalError(details.exception),
        );
      }
    };

    try {
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
        debugPrint('Warning: Failed to initialize Android Alarm Manager: $e');
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
    } catch (e, stackTrace) {
      // Handle initialization errors
      debugPrint('Error during app initialization: $e');
      ErrorHandlingService.instance
          .logError('App Initialization', e, stackTrace);

      // Show a minimal error app if we can't initialize properly
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Unable to start the application',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }, (error, stackTrace) {
    // This catches errors outside of the Flutter framework
    debugPrint('FATAL ERROR: $error');
    debugPrint(stackTrace.toString());

    ErrorHandlingService.instance.logError('Dart Runtime', error, stackTrace);

    // Show UI error if possible
    if (navigatorKey.currentContext != null) {
      ErrorHandlingService.instance.showErrorToUser(
        navigatorKey.currentContext!,
        'Unexpected error occurred',
        fatal: true,
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
