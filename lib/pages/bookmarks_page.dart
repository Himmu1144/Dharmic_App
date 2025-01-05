import 'package:dharmic/pages/bookmark_slider_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart'; // Add this import
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dharmic/components/circle_button.dart';
import 'package:dharmic/pages/search_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          _isVisible = false;
          _animationController.reverse();
        }
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isVisible) {
          _isVisible = true;
          _animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleUnbookmark(
      BuildContext context, Quote quote, IsarService isarService) async {
    await isarService.toggleBookmark(quote);
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchPage(
          searchBookmarksOnly: true,
          placeholder: "Search in your bookmarks...",
        ),
      ),
    );
  }

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
      floatingActionButton: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 2), // Slides from 2x the height (below screen)
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        )),
        child: CircleButton(
          icon: Icons.search,
          onPressed: _openSearch,
        ),
      ),
      body: Consumer<IsarService>(
        builder: (context, isarService, child) {
          return FutureBuilder<List<Quote>>(
            future: isarService.fetchBookmarkedQuotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade900,
                    highlightColor: Colors.grey.shade800,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 64, color: Colors.grey.shade600),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save your favorite quotes here',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              final bookmarkedQuotes = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  controller: _scrollController, // Add this line
                  itemCount: bookmarkedQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = bookmarkedQuotes[index];
                    return Dismissible(
                      key: Key(quote.id.toString()),
                      direction:
                          DismissDirection.horizontal, // Allow both directions
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Unbookmark action
                          await isarService.toggleBookmark(quote);
                          return true;
                        } else if (direction == DismissDirection.startToEnd) {
                          // Share action
                          await Share.share(
                            '"${quote.quote}"\n\n- ${quote.author}\n\nShared via Dharmic Quotes App',
                          );
                          return false; // Don't remove the item after sharing
                        }
                        return false;
                      },
                      background: Container(
                        // Share background (slide right)
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.green,
                        child: const Icon(Icons.share, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        // Delete background (slide left)
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Color(0xFFfa5620),
                        child: const Icon(Icons.bookmark_remove,
                            color: Colors.white),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
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
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.share),
                                            onPressed: () => Share.share(
                                              '"${quote.quote}"\n\n- ${quote.author}\n\nShared via Dharmic Quotes App',
                                            ),
                                          ),
                                          StatefulBuilder(
                                            builder: (context, setState) {
                                              return IconButton(
                                                icon: Icon(
                                                  quote.isBookmarked
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  final animationKey =
                                                      GlobalKey();
                                                  setState(() {});
                                                  _handleUnbookmark(context,
                                                      quote, isarService);
                                                },
                                              ).animate(
                                                key: ValueKey(quote.id),
                                                effects: [
                                                  const ScaleEffect(
                                                    duration: Duration(
                                                        milliseconds: 200),
                                                    curve: Curves.easeInOut,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
