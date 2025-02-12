import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dharmic/pages/author_page.dart';
import 'package:dharmic/pages/bookmarks_page.dart';
import 'package:dharmic/pages/home_page.dart';
import 'package:dharmic/pages/search_page.dart';
import 'package:dharmic/pages/settings_page.dart';
import 'package:dharmic/pages/splash_screen.dart';
import 'package:dharmic/services/notification_service.dart';
import 'package:dharmic/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

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
      home: AppStartScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/searchpage': (context) => const SearchPage(),
        '/author': (context) => const AuthorPage(),
        '/bookmarks': (context) => const BookmarksPage(),
      },
    );
  }
}

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({Key? key}) : super(key: key);

  @override
  _AppStartScreenState createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _isFirstLaunch = false; // You can modify this based on your Isar check

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // Add your Isar check logic here
    setState(() {
      _isFirstLaunch = false; // Set based on your requirements
    });
  }

  void _onSplashComplete() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onComplete: _onSplashComplete);
  }
}
