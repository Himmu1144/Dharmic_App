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

  // Initialize the IsarService and load quotes from JSON into Isar if it's the first time
  final isarService = IsarService();
  await isarService.db; // Ensure the Isar DB is initialized first

  // Load quotes from JSON if they haven't been loaded before
  await loadQuotesFromJson(isarService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<IsarService>(create: (context) => isarService),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> loadQuotesFromJson(IsarService isarService) async {
  final isar = await isarService.db;

  // Check if the quotes are already in the database to avoid loading again
  final quoteCount = await isar.quotes.count();
  if (quoteCount > 0) {
    print('Quotes Already Exists!');
    return; // Quotes already exist in the database
  }

  try {
    // Load the quotes JSON data from the assets
    final String jsonData = await rootBundle.loadString('assets/quotes.json');

    // Parse the JSON string into a list of dynamic objects
    final List<dynamic> quotesList = json.decode(jsonData);

    // Map the parsed JSON data to a list of Quote objects
    final List<Quote> quotes = quotesList.map((data) {
      return Quote(
        quote: data['quote'] ?? '',
        author: data['author'] ?? '',
        authorImg: data['author_img'] ?? '',
      );
    }).toList();

    // Write the quotes to the Isar database
    await isar.writeTxn(() async {
      await isar.quotes.putAll(quotes); // Insert all the quotes into Isar
    });

    print('Quotes imported successfully!');
  } catch (e) {
    print('Failed to load quotes: $e');
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
        '/settings': (context) => const SettingsPage(), // Define the route here
        '/bookmarks': (context) =>
            const BookmarksPage(), // Define the route here
      },
    );
  }
}
