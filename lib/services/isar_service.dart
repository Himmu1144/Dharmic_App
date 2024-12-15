import 'dart:io';
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

  // Toggle bookmark status for a quote
  Future<void> toggleBookmark(Quote quote) async {
    final isar = await db;
    await isar.writeTxn(() async {
      quote.isBookmarked = !quote.isBookmarked;
      await isar.quotes.put(quote);
    });
    await _fetchQuotes(isar); // Refresh quotes and notify listeners
  }

  // Fetch only bookmarked quotes
  Future<List<Quote>> fetchBookmarkedQuotes() async {
    final isar = await db;
    return await isar.quotes.filter().isBookmarkedEqualTo(true).findAll();
  }
}
