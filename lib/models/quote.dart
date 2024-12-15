import 'package:isar/isar.dart';

part 'quote.g.dart'; // Required for code generation

@Collection()
class Quote {
  Id id = Isar.autoIncrement; // Automatically assigns an ID
  late String quote; // The quote text
  late String author; // Name of the author
  late String authorImg; // Path to the author's image
  bool isRead = false; // Tracks if the quote has been read
  bool isBookmarked = false;

  // Constructor for convenience (optional)
  Quote({
    required this.quote,
    required this.author,
    required this.authorImg,
    this.isRead = false,
    this.isBookmarked = false,
  });
}
