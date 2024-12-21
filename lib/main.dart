import 'dart:convert';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/pages/bookmarks_page.dart';
import 'package:dharmic/pages/home_page.dart';
import 'package:dharmic/pages/settings_page.dart';
import 'package:dharmic/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await isarService.db; // Initialize Isar

  await loadQuotesFromJson(isarService); // Load quotes if needed

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<IsarService>(
          create: (context) => isarService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> loadQuotesFromJson(IsarService isarService) async {
  final isar = await isarService.db;

  if ((await isar.quotes.count()) > 0) return; // Quotes already exist

  try {
    final String jsonData = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> quotesList = json.decode(jsonData);

    final List<Quote> quotes = quotesList.map((data) {
      return Quote(
        quote: data['quote'] ?? '',
        author: data['author'] ?? 'Unknown',
        authorImg: data['author_img'] ?? 'assets/images/default_author.png',
      );
    }).toList();

    await isar.writeTxn(() => isar.quotes.putAll(quotes));
    await isarService.refreshQuotes(); // Refresh unread quotes
  } catch (e) {
    print('Error loading quotes: $e');
  }
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
        '/settings': (context) => const SettingsPage(),
        '/bookmarks': (context) => const BookmarksPage(),
      },
    );
  }
}
