import 'package:isar/isar.dart';
import 'quote.dart';

part 'author.g.dart';

@Collection()
class Author {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late String image;
  late String title;
  late String description;
  late String link;

  // Update the backlink to reference the correct property
  @Backlink(to: 'author')
  final quotes = IsarLinks<Quote>();
}
