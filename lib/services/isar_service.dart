import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier
import '../models/quote.dart';

class IsarService extends ChangeNotifier {
  late Future<Isar> db;
  List<Quote> _quotes = [];

  List<Quote> get quotes => _quotes;

  IsarService() {
    db = _initIsar();
  }

  // Add this public method
  void updateQuotes() {
    notifyListeners();
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [QuoteSchema],
      directory: dir.path,
    );
    await _fetchQuotes(isar);
    return isar;
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
      quote.bookmarkedAt =
          quote.isBookmarked ? DateTime.now() : null; // Add this line
      await isar.quotes.put(quote);
    });
    notifyListeners();
  }

  Future<List<Quote>> fetchBookmarkedQuotes() async {
    final isar = await db;
    return await isar.quotes
        .filter()
        .isBookmarkedEqualTo(true)
        .sortByBookmarkedAtDesc() // Add this line
        .findAll();
  }
}
