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

  // Add this method to your IsarService class
  Future<T?> _executeDatabaseOperation<T>(
    Future<T> Function() databaseOperation,
    String operationName, {
    T? defaultValue,
    bool notify = true,
  }) async {
    try {
      final result = await databaseOperation();
      return result;
    } catch (e, stackTrace) {
      // Log the error for debugging
      debugPrint('Database error in $operationName: $e');
      debugPrint(stackTrace.toString());

      // You can integrate with ErrorHandlingService later
      // ErrorHandlingService.instance.logError(operationName, e, stackTrace);

      // Return default value or null
      return defaultValue;
    } finally {
      if (notify) {
        notifyListeners();
      }
    }
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
    try {
      if (isSpeaking && currentQuote == quote) {
        await flutterTts.stop();
        isSpeaking = false;
        speakIcon = Icons.play_arrow;
        currentQuote = null;
      } else {
        if (isSpeaking) {
          await flutterTts.stop();
        }

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
      }
    } catch (e, stackTrace) {
      // Enhanced error handling
      debugPrint('Text-to-speech error: $e');
      debugPrint(stackTrace.toString());

      // Reset state to ensure UI is consistent
      isSpeaking = false;
      speakIcon = Icons.play_arrow;
      currentQuote = null;
    } finally {
      notifyListeners();
    }
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

  Future<Quote?> getRandomUnreadQuoteNotif() async {
    return await _executeDatabaseOperation<Quote?>(() async {
      final lang = await getSelectedLanguage();

      // First try: Get unread quotes in the selected language
      final unreadQuotes = await isar.quotes
          .filter()
          .isReadEqualTo(false)
          .languageEqualTo(lang)
          .findAll();

      if (unreadQuotes.isNotEmpty) {
        unreadQuotes.shuffle(); // Properly shuffle all results
        return unreadQuotes.first; // Return first from shuffled results
      }

      // Second try: If no unread quotes, reset quote read status and try again
      await isar.writeTxn(() async {
        // Reset all quotes in user's language to unread
        final allLangQuotes =
            await isar.quotes.filter().languageEqualTo(lang).findAll();

        for (var q in allLangQuotes) {
          q.isRead = false;
        }
        await isar.quotes.putAll(allLangQuotes);
      });

      // Get newly reset quotes and return a random one
      final refreshedQuotes = await isar.quotes
          .filter()
          .isReadEqualTo(false)
          .languageEqualTo(lang)
          .findAll();

      if (refreshedQuotes.isNotEmpty) {
        refreshedQuotes.shuffle();
        return refreshedQuotes.first;
      }

      // Last resort: Get any quote in the selected language
      final anyQuote =
          await isar.quotes.filter().languageEqualTo(lang).findAll();

      if (anyQuote.isNotEmpty) {
        anyQuote.shuffle();
        return anyQuote.first;
      }

      return null; // No quotes available in this language
    }, 'getRandomUnreadQuote');
  }

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
        print('Looking for author: ${data['tag']}');
        final author =
            await isar.authors.where().nameEqualTo(data['tag']).findFirst();

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

  // Future<List<Author>> fetchAllAuthors(
  //     {AuthorSort sort = AuthorSort.default_order}) async {
  //   // First, load your tags data
  //   final String tagsJsonData =
  //       await rootBundle.loadString('assets/author_tags.json');
  //   final List<dynamic> tagsData = json.decode(tagsJsonData);

  //   // Create a set of tag names to filter by
  //   Set<String> validTagNames = {};
  //   Set<String> excludedTags = {'Hinduism', 'Sikhism', 'Jainism'};

  //   // Extract tag names from author_tags.json
  //   for (var tagEntry in tagsData) {
  //     String tagName = tagEntry['Tag'];

  //     // Skip the excluded tags
  //     if (!excludedTags.contains(tagName)) {
  //       validTagNames.add(tagName);
  //     }
  //   }

  //   print("Valid tag names: $validTagNames");

  //   // Get all authors
  //   List<Author> allAuthors = await isar.authors.where().findAll();
  //   print("Total authors in database: ${allAuthors.length}");

  //   // Print all author names for debugging
  //   print("All author names: ${allAuthors.map((a) => a.name).toList()}");

  //   // Filter authors to include only those that are tags and not in the excluded list
  //   List<Author> filteredAuthors = allAuthors
  //       .where((author) => validTagNames.contains(author.name))
  //       .toList();

  //   print("Filtered authors count: ${filteredAuthors.length}");
  //   print(
  //       "Filtered author names: ${filteredAuthors.map((a) => a.name).toList()}");

  //   // Apply sorting
  //   switch (sort) {
  //     case AuthorSort.alphabetical:
  //       filteredAuthors.sort((a, b) => a.name.compareTo(b.name));
  //       break;
  //     case AuthorSort.quote_count:
  //       for (var author in filteredAuthors) {
  //         author.quotes.load();
  //       }
  //       filteredAuthors
  //           .sort((a, b) => b.quotes.length.compareTo(a.quotes.length));
  //       break;
  //     default:
  //       // Keep the default order
  //       break;
  //   }

  // new fetchall

  Future<List<Author>> fetchAllAuthors(
      {AuthorSort sort = AuthorSort.default_order}) async {
    try {
      // Set of tags to exclude
      Set<String> excludedTags = {'Hinduism', 'Sikhism', 'Jainism'};

      // Get all authors from database
      List<Author> allAuthors = await isar.authors.where().findAll();
      print("Total authors in database: ${allAuthors.length}");

      // Filter out the excluded tags
      List<Author> filteredAuthors = allAuthors
          .where((author) => !excludedTags.contains(author.name))
          .toList();

      print("Authors after excluding religions: ${filteredAuthors.length}");

      // Apply sorting to filtered authors
      switch (sort) {
        case AuthorSort.alphabetical:
          filteredAuthors.sort((a, b) => a.name.compareTo(b.name));
          break;
        case AuthorSort.quote_count:
          for (var author in filteredAuthors) {
            author.quotes.load();
          }
          filteredAuthors
              .sort((a, b) => b.quotes.length.compareTo(a.quotes.length));
          break;
        default:
          // Keep the default order
          break;
      }

      return filteredAuthors; // Return filtered authors
    } catch (e, stackTrace) {
      print("Error in fetchAllAuthors: $e");
      print(stackTrace);
      return []; // Return empty list on error
    }
  }

  //   return filteredAuthors;
  // }

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
    final result = await _executeDatabaseOperation(() async {
      final lang = await getSelectedLanguage();
      final unreadQuotes = await isar.quotes
          .filter()
          .isReadEqualTo(false)
          .languageEqualTo(lang)
          .findAll();

      if (unreadQuotes.isEmpty) {
        // Instead of resetting quotes in DB, we fetch all quotes for the language
        final allQuotes =
            await isar.quotes.filter().languageEqualTo(lang).findAll();
        // Reset in-memory flags here instead of writing to the DB
        for (var quote in allQuotes) {
          quote.isRead = false;
        }
        return allQuotes;
      }

      return unreadQuotes;
    }, 'getUnreadQuotes', defaultValue: <Quote>[]);

    return result ?? [];
  }

  Future<void> resetAllQuotesToUnread() async {
    await _executeDatabaseOperation(() async {
      await isar.writeTxn(() async {
        final allQuotes = await isar.quotes.where().findAll();
        for (var quote in allQuotes) {
          quote.isRead = false;
          await isar.quotes.put(quote);
        }
      });
      return null;
    }, 'resetAllQuotesToUnread');
  }

  Future<void> updateLanguage(String newLang) async {
    await _executeDatabaseOperation(() async {
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
      return null;
    }, 'updateLanguage');
  }

  // Future<List<Quote>> fetchQuotesByAuthor(Author author) async {
  //   final quotes = await isar.quotes
  //       .filter()
  //       .author((q) => q.idEqualTo(author.id))
  //       .findAll();
  //   return quotes;
  // }

  // this fetchquotesbyauthor is not working as intended but i think it'll do for now will change it later.
  Future<List<Quote>> fetchQuotesByAuthor(Author author) async {
    print("Fetching quotes for author: ${author.name}"); // Debug logging

    // Load the selected language
    final lang = await getSelectedLanguage();

    // Load tags data
    final String tagsJsonData =
        await rootBundle.loadString('assets/author_tags.json');
    final List<dynamic> tagsData = json.decode(tagsJsonData);

    List<Quote> allQuotes = [];
    bool foundTag = false;

    // Case-insensitive author name for comparison
    String authorNameLower = author.name.toLowerCase();

    // First approach: Check if the author is a tag and get all authors under that tag
    for (var tagEntry in tagsData) {
      String tagName = tagEntry['Tag'];
      print(
          "Comparing tag: $tagName with author: ${author.name}"); // Debug logging

      // Use case-insensitive comparison
      if (tagName.toLowerCase() == authorNameLower) {
        print("Found matching tag: $tagName"); // Debug logging
        foundTag = true;
        List<String> authorsUnderTag = List<String>.from(tagEntry['authors']);
        print("Authors under this tag: $authorsUnderTag"); // Debug logging

        // Handle special cases for problematic tags
        if (author.name == "Upanishads" ||
            author.name.toLowerCase() == "upanishads") {
          // Find all upanishad authors
          print("Special handling for Upanishads");
          final upanishadAuthors = await isar.authors
              .filter()
              .nameContains("Upanishad", caseSensitive: false)
              .findAll();

          for (var upanishadAuthor in upanishadAuthors) {
            var quotes = await isar.quotes
                .filter()
                .author((q) => q.idEqualTo(upanishadAuthor.id))
                .languageEqualTo(lang)
                .findAll();

            allQuotes.addAll(quotes);
            print("Added ${quotes.length} quotes from ${upanishadAuthor.name}");
          }
        } else if (author.name == "ISCON" ||
            author.name.toLowerCase() == "iscon") {
          print("Special handling for ISCON");
          // Try both ISCON and ISKCON spellings
          var bhaktivedanta = await isar.authors
              .filter()
              .nameContains("Bhaktivedanta", caseSensitive: false)
              .or()
              .nameContains("ISCON", caseSensitive: false)
              .findAll();

          for (var iskconAuthor in bhaktivedanta) {
            var quotes = await isar.quotes
                .filter()
                .author((q) => q.idEqualTo(iskconAuthor.id))
                .languageEqualTo(lang)
                .findAll();

            allQuotes.addAll(quotes);
            print("Added ${quotes.length} quotes from ${iskconAuthor.name}");
          }
        } else if (author.name == "Buddhism" ||
            author.name.toLowerCase() == "buddhism") {
          print("Special handling for Buddhism");
          // Look for Buddha or Buddhism related authors
          // Modified search to handle the name format "Siddhartha Gautama (Buddha)"
          var buddhistAuthors = await isar.authors
              .filter()
              .group((q) => q
                  .nameContains("Buddha", caseSensitive: false)
                  .or()
                  .nameContains("buddhism", caseSensitive: false)
                  .or()
                  .nameContains("buddha", caseSensitive: false)
                  .or()
                  .nameContains("Gautama", caseSensitive: false)
                  .or()
                  .nameContains("Buddhism", caseSensitive: false)
                  .or()
                  .nameEqualTo("Siddhartha Gautama (Buddha)"))
              .findAll();

          for (var buddhistAuthor in buddhistAuthors) {
            var quotes = await isar.quotes
                .filter()
                .author((q) => q.idEqualTo(buddhistAuthor.id))
                .languageEqualTo(lang)
                .findAll();

            allQuotes.addAll(quotes);
            print("Added ${quotes.length} quotes from ${buddhistAuthor.name}");
          }
        } else {
          // Standard case - fetch quotes from each author under this tag

          // Standard case - fetch quotes from each author under this tag
// Use a more flexible search approach for the tag itself
          var tagAuthors = await isar.authors
              .filter()
              .nameContains(tagName, caseSensitive: false)
              .findAll();

          print(
              "Found ${tagAuthors.length} authors matching tag: ${author.name}");

// Process all matching tag authors
          for (var matchedAuthor in tagAuthors) {
            var quotes = await isar.quotes
                .filter()
                .author((q) => q.idEqualTo(matchedAuthor.id))
                .languageEqualTo(lang)
                .findAll();

            if (quotes.isEmpty) {
              quotes = await isar.quotes
                  .filter()
                  .author((q) => q.idEqualTo(matchedAuthor.id))
                  .findAll();
            }

            allQuotes.addAll(quotes);
            print("Added ${quotes.length} quotes from ${matchedAuthor.name}");
          }

// If no authors were found with the flexible search or no quotes were found
          if (allQuotes.isEmpty) {
            print("No authors or quotes found for tag: ${author.name}");
          }
        }
        break;
      }
    }

    // Second approach: If author is not a tag, check if author belongs to any tag
    if (!foundTag) {
      print("Not found as a tag, checking if author belongs to any tag");
      bool foundAsAuthorUnderTag = false;

      // Check each tag to see if this author is listed under it
      for (var tagEntry in tagsData) {
        List<String> authorsUnderTag = List<String>.from(tagEntry['authors']);

        // Case-insensitive search
        if (authorsUnderTag
            .any((name) => name.toLowerCase() == authorNameLower)) {
          foundAsAuthorUnderTag = true;
          String tagName = tagEntry['Tag'];
          print("Author found under tag: $tagName");

          // Get the tag author
          final tagAuthor =
              await isar.authors.filter().nameEqualTo(tagName).findFirst();

          if (tagAuthor != null) {
            // Recursively call this method with the tag author to get all quotes
            return fetchQuotesByAuthor(tagAuthor);
          }
        }
      }

      // If author is neither a tag nor under any tag, just get their quotes directly
      if (!foundAsAuthorUnderTag) {
        print("Author not found in any tag, fetching direct quotes");
        var quotes = await isar.quotes
            .filter()
            .author((q) => q.idEqualTo(author.id))
            .languageEqualTo(lang)
            .findAll();

        if (quotes.isEmpty) {
          quotes = await isar.quotes
              .filter()
              .author((q) => q.idEqualTo(author.id))
              .findAll();
        }

        allQuotes.addAll(quotes);
        print("Added ${quotes.length} direct quotes from ${author.name}");
      }
    }

    print("Total quotes found for ${author.name}: ${allQuotes.length}");
    return allQuotes;
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
      await _executeDatabaseOperation(() async {
        quote.isRead = true;
        await isar.writeTxn(() async {
          await isar.quotes.put(quote);
        });
        return null;
      }, 'markQuoteAsRead');
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
    return await _executeDatabaseOperation<Quote?>(() async {
      final lang = await getSelectedLanguage();
      final unreadQuotes = await isar.quotes
          .filter()
          .isReadEqualTo(false)
          .languageEqualTo(lang)
          .findAll();

      if (unreadQuotes.isEmpty) {
        // Fallback to fetching all quotes in the selected language
        final allQuotes =
            await isar.quotes.filter().languageEqualTo(lang).findAll();
        if (allQuotes.isEmpty) return null;
        allQuotes.shuffle();
        return allQuotes.first;
      }

      final random = Random();
      return unreadQuotes.isEmpty
          ? null
          : unreadQuotes[random.nextInt(unreadQuotes.length)];
    }, 'getRandomUnreadQuote');
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
    await _executeDatabaseOperation(() async {
      final settings = AppSettings(
        isFirstLaunch: false,
        selectedLanguage: language,
      );

      await isar.writeTxn(() async {
        await isar.appSettings.clear();
        await isar.appSettings.put(settings);
      });
      return null;
    }, 'setFirstLaunchComplete');
  }

  Future<Quote?> getQuoteById(int id) async {
    return await _executeDatabaseOperation<Quote?>(
      () => isar.quotes.get(id),
      'getQuoteById',
      notify: false,
    );
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
