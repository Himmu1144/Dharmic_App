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
import 'package:dharmic/services/notification_service.dart';
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

  // Pass the Isar instance to IsarService
  final isarService = IsarService(isar);

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
      home: const AppStartScreen(),
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
  const AppStartScreen({super.key});

  @override
  _AppStartScreenState createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  late IsarService _isarService;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _isarService = Provider.of<IsarService>(context, listen: false);
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await _isarService.isFirstLaunch();
    setState(() {
      _isFirstLaunch = isFirst;
    });
  }

  // void _onSplashComplete() {
  //   if (_isFirstLaunch) {
  //     Navigator.pushReplacement(
  //       context,
  //       _createSlideUpRoute(const HomePage()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LanguageSelectionScreen(
  //           onLanguageSelected: _onLanguageSelected,
  //         ),
  //       ),
  //     );
  //   }
  // }
  void _onSplashComplete() {
    if (_isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageSelectionScreen(
            onLanguageSelected: _onLanguageSelected,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        _createSlideUpRoute(const HomePage()),
      );
    }
  }

  // void _onLanguageSelected(String language) async {
  //   try {
  //     await _isarService.setFirstLaunchComplete(language);
  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomePage()),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error setting language: $e');
  //     // Optionally show an error message to the user
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text('Failed to set language. Please try again.')),
  //       );
  //     }
  //   }
  // }

  void _onLanguageSelected(String language) async {
    try {
      await _isarService.setFirstLaunchComplete(language);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Error setting language: $e');
      // Optionally show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to set language. Please try again.')),
        );
      }
    }
  }

  Route _createSlideUpRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onComplete: _onSplashComplete);
  }
}
