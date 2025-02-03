import 'package:dharmic/pages/bookmark_slider_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:share_plus/share_plus.dart';
// Add this import
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

  // Add these variables
  String? _currentSort;
  late List<Quote> _bookmarkedQuotes = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // Add new variable to track positions
  final Map<int, double> _itemPositions = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    // Initialize bookmarked quotes
    _loadBookmarkedQuotes();

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

  Future<void> _loadBookmarkedQuotes() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    _bookmarkedQuotes = await isarService.fetchBookmarkedQuotes();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleUnbookmark(BuildContext context, Quote quote,
      IsarService isarService, int index) async {
    // First set isBookmarked to false to trigger slide animation
    setState(() {
      quote.isBookmarked = false;
    });

    // Wait for slide animation to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove from list
    setState(() {
      _bookmarkedQuotes.removeAt(index);
    });

    // Update in database
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

  Future<void> _sortQuotes(String sortBy) async {
    if (_currentSort == sortBy) {
      Navigator.pop(context);
      return;
    }

    final isarService = Provider.of<IsarService>(context, listen: false);
    final newSortedQuotes =
        await isarService.fetchBookmarkedQuotesSorted(sortBy: sortBy);

    // Store current positions before sorting
    for (int i = 0; i < _bookmarkedQuotes.length; i++) {
      _itemPositions[_bookmarkedQuotes[i].id] =
          i * 150.0; // Assuming each card is ~150 height
    }

    setState(() {
      _currentSort = sortBy;
      _bookmarkedQuotes = newSortedQuotes;
    });

    // Animate to new positions
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _itemPositions.clear();
    });

    // Close the bottom sheet
    Navigator.pop(context);
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
        // In the AppBar actions, add this filter button
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Update the modal code in bookmarks_page.dart
              showModalBottomSheet(
                context: context,
                backgroundColor:
                    const Color(0xFF282828), // Match AppBar background
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SingleChildScrollView(
                    // Add this to prevent overflow
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20), // Reduced horizontal padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                padding: EdgeInsets
                                    .zero, // Remove padding from IconButton
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                'Filter by',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFfa5620),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              HoverableFilterButton(
                                icon: Icons.person,
                                label: 'Author',
                                onTap: () => _sortQuotes('author'),
                              ),
                              HoverableFilterButton(
                                icon: Icons.notes_outlined,
                                label: 'Length',
                                onTap: () => _sortQuotes('length'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
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
          if (_bookmarkedQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your bookmarked quotes will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _bookmarkedQuotes.length,
              itemBuilder: (context, index) {
                final quote = _bookmarkedQuotes[index];
                final position = _itemPositions[quote.id] ?? (index * 100.0);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.zero, // Remove margin
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _itemPositions.containsKey(quote.id) ? 0.5 : 1.0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Dismissible(
                        key: Key(quote.id.toString()),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Remove the quote from the list first
                            setState(() {
                              _bookmarkedQuotes.removeAt(index);
                            });
                            // Then toggle the bookmark
                            await isarService.toggleBookmark(quote);
                            return true;
                          } else if (direction == DismissDirection.startToEnd) {
                            await Share.share(
                              '"${quote.quote}"\n\n- ${quote.author}\n\nShared via Dharmic Quotes App',
                            );
                            return false;
                          }
                          return false;
                        },
                        onDismissed: (_) {
                          // This is called after confirmDismiss returns true
                          // No need to remove the item here as we've already done it
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
                          color: const Color(0xFFfa5620),
                          child: const Icon(Icons.bookmark_remove,
                              color: Colors.white),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(
                              quote.isBookmarked
                                  ? 0
                                  : -MediaQuery.of(context).size.width,
                              0,
                              0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookmarkSliderPage(
                                    bookmarkedQuotes: _bookmarkedQuotes,
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
                                        quote.author.value?.image ?? "",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      quote.author.value?.name ?? "",
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
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
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
                                                    _handleUnbookmark(
                                                        context,
                                                        quote,
                                                        isarService,
                                                        index);
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
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// First create a new HoverableFilterButton widget
class HoverableFilterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HoverableFilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<HoverableFilterButton> createState() => _HoverableFilterButtonState();
}

class _HoverableFilterButtonState extends State<HoverableFilterButton> {
  bool isHovered = false;
  bool isPressed = false;
  bool isClickEffect = false;

  void _handleTap() async {
    setState(() {
      isClickEffect = true;
    });

    // Show effect for 2 seconds
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        isClickEffect = false;
      });
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.45,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isHovered || isPressed || isClickEffect)
                  ? const Color(0xFFfa5620).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 28,
                  color: (isHovered || isPressed || isClickEffect)
                      ? Colors.grey[400]
                      : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: (isHovered || isPressed || isClickEffect)
                        ? Colors.grey[400]
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
