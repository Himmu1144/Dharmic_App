import 'package:isar/isar.dart';
import 'author.dart';

part 'quote.g.dart';

@Collection()
class Quote {
  Id id = Isar.autoIncrement;

  late String quote;

  // Keep the read tracking
  bool isRead = false;

  @Index()
  bool isBookmarked = false;

  @Index()
  DateTime? bookmarkedAt;

  // Maintain author relationship
  @Index()
  final author = IsarLink<Author>();

  // Add these getters for backward compatibility
  String get authorName => author.value?.name ?? '';
  String get authorImg => author.value?.image ?? 'assets/images/buddha.png';

  // Constructor
  Quote({
    this.quote = '',
    this.isRead = false,
    this.isBookmarked = false,
    this.bookmarkedAt,
  });
}
