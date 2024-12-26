import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/components/my_drawer.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<IsarService>(
        builder: (context, isarService, child) {
          return FutureBuilder<List<Quote>>(
            future: isarService.fetchBookmarkedQuotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No bookmarks found.'));
              }

              final bookmarkedQuotes = snapshot.data!;
              return ListView.builder(
                itemCount: bookmarkedQuotes.length,
                itemBuilder: (context, index) {
                  final quote = bookmarkedQuotes[index];
                  return GestureDetector(
                    onTap: () {
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
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              '- ${quote.author}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () {
                                    print('Share pressed');
                                  },
                                ),
                                _CircleButton(
                                  icon: quote.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  onPressed: () async {
                                    final isarService =
                                        Provider.of<IsarService>(context,
                                            listen: false);
                                    await isarService.toggleBookmark(quote);
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
              );
            },
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _CircleButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.amber : Colors.white,
        ),
      ),
    );
  }
}
