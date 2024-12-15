import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier
import '../models/quote.dart';

class IsarService extends ChangeNotifier {
  late Future<Isar> db; // This should hold Future<Isar>, not void
  List<Quote> _quotes = [];

  List<Quote> get quotes => _quotes;

  IsarService() {
    db = _initIsar(); // Ensure db is assigned a Future<Isar>
  }

  // Initialize Isar and return the Isar instance
  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [QuoteSchema], // Register your schema here
      directory: dir.path,
    );
    await _fetchQuotes(isar);
    return isar; // Return the Isar instance here
  }

  // Fetch quotes from Isar database
  Future<void> _fetchQuotes(Isar isar) async {
    try {
      _quotes = await isar.quotes.where().findAll();
      notifyListeners(); // Notify listeners when data changes
    } catch (e) {
      print('Error fetching quotes: $e');
    }
  }

  // Method to add new quote (if necessary)
  Future<void> addQuote(Quote quote) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.quotes.put(quote);
    });
    _quotes.add(quote);
    notifyListeners();
  }
}
