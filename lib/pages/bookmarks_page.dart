import 'package:dharmic/pages/bookmark_slider_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:share_plus/share_plus.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontSize: 18),
        ),
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
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  itemCount: bookmarkedQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = bookmarkedQuotes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookmarkSliderPage(
                              bookmarkedQuotes: bookmarkedQuotes,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey.shade900,
                              Colors.grey.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  quote.authorImg,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                quote.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Spiritual Leader',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quote.quote.length > 150
                                        ? '${quote.quote.substring(0, 150)}...'
                                        : quote.quote,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade300,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () =>
                                            Share.share(quote.quote),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          quote.isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            isarService.toggleBookmark(quote),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
