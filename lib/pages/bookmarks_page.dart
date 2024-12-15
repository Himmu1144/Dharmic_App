import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Quote> bookmarkedQuotes = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedQuotes();
  }

  // Fetch bookmarked quotes from Isar
  Future<void> _loadBookmarkedQuotes() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final isar = await isarService.db;

    // Fetch bookmarked quotes
    final quotes =
        await isar.quotes.filter().isBookmarkedEqualTo(true).findAll();

    setState(() {
      bookmarkedQuotes = quotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: ListView.builder(
        itemCount: bookmarkedQuotes.length,
        itemBuilder: (context, index) {
          final quote = bookmarkedQuotes[index];
          return GestureDetector(
            onTap: () {
              // Define your onPressed function here
              print('Card tapped: ${quote.quote}');
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.quote.length > 500
                          ? '${quote.quote.substring(0, 500)}...'
                          : quote.quote,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '- ${quote.author}',
                      style: TextStyle(
                          fontSize: 14.0, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            // Define your share function here
                            print('Share pressed');
                          },
                        ),
                        _CircleButton(
                          icon: quote.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          onPressed: () async {
                            setState(() {
                              quote.isBookmarked = !quote.isBookmarked;
                            });

                            // Persist the updated bookmark state in the database
                            final isarService = Provider.of<IsarService>(
                                context,
                                listen: false);
                            final isar = await isarService.db;
                            await isar.writeTxn(() async {
                              await isar.quotes.put(quote);
                            });
                            print('Bookmark toggled: ${quote.isBookmarked}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
