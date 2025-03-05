import 'dart:math';

import 'package:dharmic/pages/author_page.dart';
import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';
import '../models/author.dart';
import '../models/app_settings.dart';

class IsarService extends ChangeNotifier {
  final Isar isar; // This is the correct instance to use instead of 'db'
  List<Quote> _quotes = [];
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  IconData speakIcon = Icons.play_arrow;
  String? currentQuote;

  List<Quote> get quotes => _quotes;

  IsarService(this.isar) {
    _setupTTS();
    _fetchQuotes(isar);
  }

  void _setupTTS() {
    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      speakIcon = Icons.play_arrow;
      currentQuote = null;
      notifyListeners();
    });
  }

  // Future<void> handleSpeech(String quote) async {
  //   if (isSpeaking && currentQuote == quote) {
  //     await flutterTts.stop();
  //     isSpeaking = false;
  //     speakIcon = Icons.play_arrow;
  //     currentQuote = null;
  //   } else {
  //     if (isSpeaking) {
  //       await flutterTts.stop();
  //     }

  //     try {
  //       await flutterTts.setLanguage("en-US");
  //       await flutterTts.setPitch(1.0);
  //       final result = await flutterTts.speak(quote);
  //       if (result == 1) {
  //         isSpeaking = true;
  //         speakIcon = Icons.stop;
  //         currentQuote = quote;
  //       }
  //     } catch (e) {
  //       isSpeaking = false;
  //       speakIcon = Icons.play_arrow;
  //       currentQuote = null;
  //     }
  //   }
  //   notifyListeners();
  // }

  Future<void> handleSpeech(String quote, String language) async {
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
        if (language == "hi") {
          await flutterTts.setLanguage("hi-IN");
        } else {
          await flutterTts.setLanguage("en-US");
        }
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

  void updateQuotes() {
    notifyListeners();
  }

  Future<void> loadAuthorsFromJson() async {
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

  // Future<void> loadQuotesWithAuthors() async {
  //   print('Authors count: ${await isar.authors.count()}');
  //   print('Quotes count: ${await isar.quotes.count()}');

  //   if (await isar.quotes.count() > 0) {
  //     print('Quotes already exist, skipping import');
  //     return;
  //   }

  //   final String jsonData = await rootBundle.loadString('assets/quotes.json');
  //   final List<dynamic> quotesList = json.decode(jsonData);
  //   print('Loaded ${quotesList.length} quotes from JSON');

  //   await isar.writeTxn(() async {
  //     for (var data in quotesList) {
  //       print('Looking for author: ${data['author']}');

  //       final author =
  //           await isar.authors.where().nameEqualTo(data['author']).findFirst();

  //       if (author != null) {
  //         print('Found author: ${author.name}');

  //         final quote = Quote()
  //           ..quote = data['quote']
  //           ..author.value = author
  //           ..isRead = false
  //           ..isBookmarked = false;

  //         await isar.quotes.put(quote);
  //         await quote.author.save();
  //       } else {
  //         print('Author not found: ${data['author']}');
  //       }
  //     }
  //   });
  // }

  Future<void> loadQuotesWithAuthors() async {
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
        final author =
            await isar.authors.where().nameEqualTo(data['author']).findFirst();

        if (author != null) {
          print('Found author: ${author.name}');

          final quote = Quote()
            ..quote = data['quote']
            ..language = data['language'] // set language here
            ..author.value = author
            ..isRead = false
            ..isBookmarked = false;

          await isar.quotes.put(quote);
          await quote.author.save();
        } else {
          print('Author not found: ${data['author']}');
        }
      }
    });
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
    await isar.writeTxn(() async {
      quote.isBookmarked = !quote.isBookmarked;
      quote.bookmarkedAt = quote.isBookmarked ? DateTime.now() : null;
      await isar.quotes.put(quote);
    });
    notifyListeners();
  }

  Future<List<Quote>> fetchBookmarkedQuotes() async {
    return await isar.quotes
        .filter()
        .isBookmarkedEqualTo(true)
        .sortByBookmarkedAtDesc()
        .findAll();
  }

  Future<List<Quote>> fetchBookmarkedQuotesSorted({String? sortBy}) async {
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
    return isar.quotes
        .filter()
        .group((q) => q
            .quoteContains(query, caseSensitive: false)
            .or()
            .author((q) => q.nameContains(query, caseSensitive: false)))
        .findAll();
  }

  Future<List<Quote>> searchBookmarkedQuotes(String query) async {
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
    final quotes = await isar.quotes.where().findAll();

    final authorMap = <String, String>{};
    for (var quote in quotes) {
      if (quote.author.value != null) {
        authorMap[quote.author.value!.name] = quote.author.value!.image;
      }
    }

    return authorMap.entries
        .map((entry) => {
              'name': entry.key,
              'image': entry.value,
            })
        .toList();
  }

  Future<List<Author>> fetchAllAuthors(
      {AuthorSort sort = AuthorSort.default_order}) async {
    List<Author> authors;

    switch (sort) {
      case AuthorSort.alphabetical:
        authors = await isar.authors.where().sortByName().findAll();
        break;
      case AuthorSort.quote_count:
        authors = await isar.authors.where().findAll();
        for (var author in authors) {
          author.quotes.load();
        }
        authors.sort((a, b) => b.quotes.length.compareTo(a.quotes.length));
        break;
      default:
        authors = await isar.authors.where().findAll();
    }
    return authors;
  }

  // Future<List<Quote>> getUnreadQuotes() async {
  //   final unreadQuotes =
  //       await isar.quotes.filter().isReadEqualTo(false).findAll();

  //   if (unreadQuotes.isEmpty) {
  //     await isar.writeTxn(() async {
  //       final allQuotes = await isar.quotes.where().findAll();
  //       for (var quote in allQuotes) {
  //         quote.isRead = false;
  //       }
  //       await isar.quotes.putAll(allQuotes);
  //     });

  //     return await isar.quotes.filter().isReadEqualTo(false).findAll();
  //   }

  //   return unreadQuotes;
  // }

  Future<List<Quote>> getUnreadQuotes() async {
    final lang = await getSelectedLanguage();
    final unreadQuotes = await isar.quotes
        .filter()
        .isReadEqualTo(false)
        .languageEqualTo(lang) // filter by language
        .findAll();

    if (unreadQuotes.isEmpty) {
      // Instead of resetting quotes in the DB, we can simply fetch all quotes for the language.
      // (Alternatively, you could still perform the reset if you prefer.)
      final allQuotes =
          await isar.quotes.filter().languageEqualTo(lang).findAll();
      // Optionally, you could reset in-memory flags here instead of writing to the DB.
      for (var quote in allQuotes) {
        quote.isRead = false;
      }
      return allQuotes;
    }

    return unreadQuotes;
  }

  Future<void> resetAllQuotesToUnread() async {
    await isar.writeTxn(() async {
      final allQuotes = await isar.quotes.where().findAll();
      for (var quote in allQuotes) {
        quote.isRead = false;
        await isar.quotes.put(quote);
      }
    });
  }

  Future<void> updateLanguage(String newLang) async {
    // This operation is asynchronous; ensure it doesn't block the UI.
    final settings = await isar.appSettings.where().findFirst();
    if (settings == null) {
      final newSettings = AppSettings(
        isFirstLaunch: false,
        selectedLanguage: newLang,
      );
      await isar.writeTxn(() async {
        await isar.appSettings.put(newSettings);
      });
    } else {
      settings.selectedLanguage = newLang;
      await isar.writeTxn(() async {
        await isar.appSettings.put(settings);
      });
    }
    notifyListeners();
  }

  // Future<List<Quote>> fetchQuotesByAuthor(Author author) async {
  //   final quotes = await isar.quotes
  //       .filter()
  //       .author((q) => q.idEqualTo(author.id))
  //       .findAll();
  //   return quotes;
  // }

  Future<List<Quote>> fetchQuotesByAuthor(Author author) async {
    final lang = await getSelectedLanguage();

    // Try to fetch quotes in the selected language.
    var quotes = await isar.quotes
        .filter()
        .author((q) => q.idEqualTo(author.id))
        .languageEqualTo(lang)
        .findAll();

    // If no quotes are found for that language, fetch all quotes for the author.
    if (quotes.isEmpty) {
      quotes = await isar.quotes
          .filter()
          .author((q) => q.idEqualTo(author.id))
          .findAll();
    }

    return quotes;
  }

  Future<void> loadNextQuotes(List<Quote> currentQuotes) async {
    // final newQuotes = await isar.quotes
    //     .filter()
    //     .isReadEqualTo(false)
    //     .and()
    //     .not()
    //     .group((q) =>
    //         q.anyOf(currentQuotes.map((q) => q.id), (q, id) => q.idEqualTo(id)))
    //     .limit(5)
    //     .findAll();
    final lang = await getSelectedLanguage();
    final newQuotes = await isar.quotes
        .filter()
        .isReadEqualTo(false)
        .languageEqualTo(lang)
        .and() // if needed, depending on how you chain other filters
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
      quote.isRead = true;
      await isar.writeTxn(() async {
        await isar.quotes.put(quote);
      });
      notifyListeners();
    }
  }

  // Future<Quote?> getRandomUnreadQuote() async {
  //   final unreadQuotes =
  //       await isar.quotes.filter().isReadEqualTo(false).findAll();

  //   if (unreadQuotes.isEmpty) {
  //     await resetAllQuotesToUnread();
  //     return getRandomUnreadQuote();
  //   }

  //   final random = Random();
  //   return unreadQuotes[random.nextInt(unreadQuotes.length)];
  // }

  Future<Quote?> getRandomUnreadQuote() async {
    final lang = await getSelectedLanguage();
    final unreadQuotes = await isar.quotes
        .filter()
        .isReadEqualTo(false)
        .languageEqualTo(lang) // filter by language
        .findAll();

    if (unreadQuotes.isEmpty) {
      // Instead of resetting the DB, fallback to fetching all quotes in the selected language.
      final allQuotes =
          await isar.quotes.filter().languageEqualTo(lang).findAll();
      if (allQuotes.isEmpty) return null;
      allQuotes.shuffle();
      return allQuotes.first;
    }

    final random = Random();
    return unreadQuotes[random.nextInt(unreadQuotes.length)];
  }

  Future<int> findQuoteIndex(Quote quote) async {
    final allQuotes = await isar.quotes.where().findAll();
    return allQuotes.indexWhere((q) => q.id == quote.id);
  }

  Future<bool> isFirstLaunch() async {
    try {
      final settings = await isar.appSettings.where().findFirst();
      final result = settings?.isFirstLaunch ?? true;
      print('isFirstLaunch check result: $result'); // Add logging
      return result;
    } catch (e) {
      print('Error checking first launch: $e'); // Add error logging
      return true; // Default to true on error
    }
  }

  // Future<void> clearAllSettings() async {
  //   await isar.writeTxn(() async {
  //     await isar.appSettings.clear();
  //   });
  //   notifyListeners();
  // }

  Future<void> setFirstLaunchComplete(String language) async {
    print('Starting setFirstLaunchComplete with language: $language');
    try {
      final settings = AppSettings(
        isFirstLaunch: false,
        selectedLanguage: language,
      );

      print('About to start write transaction');
      await isar.writeTxn(() async {
        print('Clearing existing settings...');
        await isar.appSettings.clear();
        print('Adding new settings...');
        await isar.appSettings.put(settings);
        print('Write transaction completed');
      });

      print('Notifying listeners');
      notifyListeners();
      print('Language setting complete: $language');
    } catch (e) {
      print('Error in setFirstLaunchComplete: $e');
      rethrow;
    }
  }

  Future<String> getSelectedLanguage() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.selectedLanguage ?? 'en';
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
