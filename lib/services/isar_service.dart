import 'dart:math';

import 'package:dharmic/pages/author_page.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Add this
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';
import '../models/author.dart';

class IsarService extends ChangeNotifier {
  late Future<Isar> db;
  List<Quote> _quotes = [];
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  IconData speakIcon = Icons.play_arrow;
  String? currentQuote;

  List<Quote> get quotes => _quotes;

  IsarService() {
    db = _initIsar();
    _setupTTS();
  }

  void _setupTTS() {
    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      speakIcon = Icons.play_arrow;
      currentQuote = null;
      notifyListeners();
    });
  }

  Future<void> handleSpeech(String quote) async {
    if (isSpeaking && currentQuote == quote) {
      await flutterTts.stop();
      isSpeaking = false;
      speakIcon = Icons.play_arrow;
      currentQuote = null;
    } else {
      if (isSpeaking) {
        await flutterTts.stop();
      }

      try {
        await flutterTts.setLanguage("en-US");
        await flutterTts.setPitch(1.0);
        final result = await flutterTts.speak(quote);
        if (result == 1) {
          isSpeaking = true;
          speakIcon = Icons.stop;
          currentQuote = quote;
        }
      } catch (e) {
        isSpeaking = false;
        speakIcon = Icons.play_arrow;
        currentQuote = null;
      }
    }
    notifyListeners();
  }

  // Add this public method
  void updateQuotes() {
    notifyListeners();
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [AuthorSchema, QuoteSchema],
      directory: dir.path,
    );
    await _fetchQuotes(isar);
    return isar;
  }

  Future<void> loadAuthorsFromJson() async {
    final isar = await db;

    // Check if authors exist
    if (await isar.authors.count() > 0) return;

    final String jsonData = await rootBundle.loadString('assets/author.json');
    final List<dynamic> authorsList = json.decode(jsonData);

    await isar.writeTxn(() async {
      for (var data in authorsList) {
        final author = Author()
          ..name = data['author']
          ..image = data['author_img']
          ..title = data['author_title']
          ..description = data['author_description']
          ..link = data['author_link'];
        await isar.authors.put(author);
      }
    });
  }

  Future<void> loadQuotesWithAuthors() async {
    final isar = await db;

    // Debug print to check counts
    print('Authors count: ${await isar.authors.count()}');
    print('Quotes count: ${await isar.quotes.count()}');

    if (await isar.quotes.count() > 0) {
      print('Quotes already exist, skipping import');
      return;
    }

    final String jsonData = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> quotesList = json.decode(jsonData);
    print('Loaded ${quotesList.length} quotes from JSON');

    await isar.writeTxn(() async {
      for (var data in quotesList) {
        print('Looking for author: ${data['author']}');

        // Find author with exact name match
        final author =
            await isar.authors.where().nameEqualTo(data['author']).findFirst();

        if (author != null) {
          print('Found author: ${author.name}');

          final quote = Quote()
            ..quote = data['quote']
            ..author.value = author
            ..isRead = false
            ..isBookmarked = false;

          // Save quote
          await isar.quotes.put(quote);

          // Establish bidirectional link
          await quote.author.save();
        } else {
          print('Author not found: ${data['author']}');
        }
      }
    });

    //   // Verify relationships
    //   final quotes = await isar.quotes.where().findAll();
    //   print('\nVerifying relationships:');
    //   for (var quote in quotes) {
    //     print('Quote: ${quote.quote.substring(0, 20)}...');
    //     print('Author: ${quote.author.value?.name ?? 'NO AUTHOR'}\n');
    //   }
  }

  Future<void> _fetchQuotes(Isar isar) async {
    try {
      _quotes = await isar.quotes.where().findAll();
      notifyListeners();
    } catch (e) {
      print('Error fetching quotes: $e');
    }
  }

  Future<void> toggleBookmark(Quote quote) async {
    final isar = await db;
    await isar.writeTxn(() async {
      quote.isBookmarked = !quote.isBookmarked;
      quote.bookmarkedAt = quote.isBookmarked ? DateTime.now() : null;
      await isar.quotes.put(quote);
    });
    notifyListeners();
  }

  Future<List<Quote>> fetchBookmarkedQuotes() async {
    final isar = await db;
    return await isar.quotes
        .filter()
        .isBookmarkedEqualTo(true)
        .sortByBookmarkedAtDesc()
        .findAll();
  }

  Future<List<Quote>> fetchBookmarkedQuotesSorted({String? sortBy}) async {
    final isar = await db;
    final quotes =
        await isar.quotes.filter().isBookmarkedEqualTo(true).findAll();

    switch (sortBy) {
      case 'author':
        quotes.sort((a, b) =>
            a.author.value?.name.compareTo(b.author.value?.name ?? '') ?? 0);
        return quotes;
      case 'length':
        quotes.sort((a, b) => a.quote.length.compareTo(b.quote.length));
        return quotes;
      default:
        return quotes;
    }
  }

  Future<List<Quote>> searchAllQuotes(String query) async {
    final isar = await db;
    return isar.quotes
        .filter()
        .group((q) => q
            .quoteContains(query, caseSensitive: false)
            .or()
            .author((q) => q.nameContains(query, caseSensitive: false)))
        .findAll();
  }

  Future<List<Quote>> searchBookmarkedQuotes(String query) async {
    final isar = await db;
    return isar.quotes
        .filter()
        .isBookmarkedEqualTo(true)
        .group((q) => q
            .quoteContains(query, caseSensitive: false)
            .or()
            .author((q) => q.nameContains(query, caseSensitive: false)))
        .findAll();
  }

  Future<List<Map<String, String>>> fetchUniqueAuthors() async {
    final isar = await db;
    final quotes = await isar.quotes.where().findAll();

    // Use a map to track unique authors and their images
    final authorMap = <String, String>{};
    for (var quote in quotes) {
      if (quote.author.value != null) {
        authorMap[quote.author.value!.name] = quote.author.value!.image;
      }
    }

    // Convert to list of maps with author and image
    return authorMap.entries
        .map((entry) => {
              'name': entry.key,
              'image': entry.value,
            })
        .toList();
  }

  Future<List<Author>> fetchAllAuthors(
      {AuthorSort sort = AuthorSort.default_order}) async {
    final isar = await db;
    List<Author> authors;

    switch (sort) {
      case AuthorSort.alphabetical:
        authors = await isar.authors.where().sortByName().findAll();
        break;
      case AuthorSort.quote_count:
        authors = await isar.authors.where().findAll();
        // Load quote counts for each author
        for (var author in authors) {
          author.quotes.load();
        }
        // Sort by quote count descending
        authors.sort((a, b) => b.quotes.length.compareTo(a.quotes.length));
        break;
      default:
        authors = await isar.authors.where().findAll();
    }
    return authors;
  }

  Future<List<Quote>> getUnreadQuotes() async {
    final isar = await db;
    final unreadQuotes =
        await isar.quotes.filter().isReadEqualTo(false).findAll();

    print("Unread Quotes: ${unreadQuotes.length}");

    if (unreadQuotes.isEmpty) {
      // Reset all quotes to unread
      await isar.writeTxn(() async {
        final allQuotes = await isar.quotes.where().findAll();
        for (var quote in allQuotes) {
          quote.isRead = false;
        }
        await isar.quotes.putAll(allQuotes);
      });

      // Fetch unread quotes again
      return await isar.quotes.filter().isReadEqualTo(false).findAll();
    }

    return unreadQuotes;
  }

  Future<void> resetAllQuotesToUnread() async {
    final isar = await db;
    await isar.writeTxn(() async {
      final allQuotes = await isar.quotes.where().findAll();
      for (var quote in allQuotes) {
        quote.isRead = false;
        await isar.quotes.put(quote);
      }
    });
  }

  Future<List<Quote>> fetchQuotesByAuthor(Author author) async {
    final isar = await db;
    final quotes = await isar.quotes
        .filter()
        .author((q) => q.idEqualTo(author.id))
        .findAll();
    return quotes;
  }

  Future<void> loadNextQuotes(List<Quote> currentQuotes) async {
    final isar = await db;

    // Get more unread quotes
    final newQuotes = await isar.quotes
        .filter()
        .isReadEqualTo(false)
        .and()
        .not()
        .group((q) =>
            q.anyOf(currentQuotes.map((q) => q.id), (q, id) => q.idEqualTo(id)))
        .limit(5)
        .findAll();

    if (newQuotes.isNotEmpty) {
      currentQuotes.addAll(newQuotes);
      notifyListeners();
    }
  }

  Future<void> markQuoteAsRead(Quote quote) async {
    if (!quote.isRead) {
      final isar = await db;
      quote.isRead = true;
      await isar.writeTxn(() async {
        await isar.quotes.put(quote);
      });
      notifyListeners();
    }
  }

  Future<Quote?> getRandomUnreadQuote() async {
    final isar = await db;
    final unreadQuotes =
        await isar.quotes.filter().isReadEqualTo(false).findAll();

    if (unreadQuotes.isEmpty) {
      // Reset all quotes to unread if none are available
      await resetAllQuotesToUnread();
      return getRandomUnreadQuote();
    }

    // Get a random quote
    final random = Random();
    return unreadQuotes[random.nextInt(unreadQuotes.length)];
  }

// Add this method to handle jumping to a specific quote
  Future<int> findQuoteIndex(Quote quote) async {
    final isar = await db;
    final allQuotes = await isar.quotes.where().findAll();
    return allQuotes.indexWhere((q) => q.id == quote.id);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
