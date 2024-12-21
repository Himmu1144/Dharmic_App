import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/quote.dart';

class IsarService extends ChangeNotifier {
  late Future<Isar> db;
  final List<Quote> _unreadQuotes = [];
  final List<Quote> _viewedQuotes = [];
  int _currentIndex = 0; // Default to 0

  List<Quote> get unreadQuotes => List.unmodifiable(_unreadQuotes);
  List<Quote> get viewedQuotes => List.unmodifiable(_viewedQuotes);
  int get currentIndex => _currentIndex;

  IsarService() {
    db = _initIsar();
  }

  Future<Isar> _initIsar() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [QuoteSchema],
        directory: dir.path,
      );
      await _loadQuotes(isar);
      return isar;
    } catch (e) {
      print('Error initializing Isar: $e');
      rethrow;
    }
  }

  Future<void> _loadQuotes(Isar isar) async {
    try {
      // Load unread quotes
      final quotes = await isar.quotes.where().findAll();
      if (quotes.isNotEmpty) {
        _unreadQuotes.addAll(quotes..shuffle());
        if (_viewedQuotes.isEmpty && _unreadQuotes.isNotEmpty) {
          // Move the first quote to viewedQuotes for initial display
          final firstQuote = _unreadQuotes.removeAt(0);
          _viewedQuotes.add(firstQuote);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading quotes: $e');
    }
  }

  void loadNextQuote() {
    if (_unreadQuotes.isNotEmpty) {
      final nextQuote = _unreadQuotes.removeAt(0);
      _viewedQuotes.add(nextQuote);
      _currentIndex = _viewedQuotes.length - 1;
      notifyListeners();
    } else {
      print('No more unread quotes available.');
    }
  }

  Future<void> markAsRead() async {
    if (_currentIndex >= 0 && !_viewedQuotes[_currentIndex].isRead) {
      final isar = await db;
      final quote = _viewedQuotes[_currentIndex];
      quote.isRead = true;
      try {
        await isar.writeTxn(() async {
          await isar.quotes.put(quote);
        });
        notifyListeners();
      } catch (e) {
        print('Error marking quote as read: $e');
      }
    }
  }

  Future<void> toggleBookmark(Quote quote) async {
    final isar = await db;
    try {
      await isar.writeTxn(() async {
        quote.isBookmarked = !quote.isBookmarked;
        await isar.quotes.put(quote);
      });
      notifyListeners();
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }
}
