import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Add this
import '../models/quote.dart';

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

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
