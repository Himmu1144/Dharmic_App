import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // Add this import

class SearchPage extends StatefulWidget {
  final bool searchBookmarksOnly;
  final String? placeholder; // Add this

  const SearchPage({
    super.key,
    this.searchBookmarksOnly = false,
    this.placeholder, // Add this
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Quote>? searchResults;
  bool isLoading = false;
  bool isFabExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller first
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Then create the animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Request focus after animation initialization
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      isFabExpanded = !isFabExpanded;
      if (isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showUndoSnackbar(Quote quote, IsarService isarService) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(quote.isBookmarked ? 'Quote bookmarked' : 'Bookmark removed'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            isarService.toggleBookmark(quote);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // First unfocus the keyboard
            FocusScope.of(context).unfocus();
            // Wait for keyboard to close before popping
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode, // Use focusNode instead of autofocus
          autofocus: false, // Disable autofocus
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.placeholder ?? "What's on your mind today?",
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _performSearch(value),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchResults == null
              ? const Center(
                  child: Text(''),
                )
              : searchResults!.isEmpty
                  ? const Center(
                      child: Text('No quotes found'),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0), // Reduced vertical padding
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: searchResults!.length,
                        itemBuilder: (context, index) {
                          final quote = searchResults![index];
                          return Dismissible(
                            key: Key(quote.id.toString()),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                final isarService = Provider.of<IsarService>(
                                    context,
                                    listen: false);
                                await isarService.toggleBookmark(quote);
                                _showUndoSnackbar(quote, isarService);
                                return false;
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                await Share.share(
                                  '"${quote.quote}"\n\n- ${quote.author}\n\nShared via Dharmic Quotes App',
                                );
                                return false;
                              }
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.green,
                              child:
                                  const Icon(Icons.share, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.orange,
                              child: const Icon(Icons.bookmark_add,
                                  color: Colors.white),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8.0), // Reduced margin
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.shade900,
                                        Colors.grey.shade800,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage:
                                                  AssetImage(quote.authorImg),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Text(
                                              quote.author.value?.name ??
                                                  'Unknown',
                                              style: GoogleFonts.notoSansJp(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16.0),
                                        Text(
                                          '"${quote.quote}"',
                                          style: GoogleFonts.notoSerif(
                                            fontSize: 16.0,
                                            color: Colors.grey[300],
                                            height: 1.5,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFabExpanded) ...[
                  FloatingActionButton(
                    heroTag: 'copy',
                    mini: true,
                    child: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy quote action
                      _toggleFab();
                    },
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'share',
                    mini: true,
                    child: const Icon(Icons.share),
                    onPressed: () {
                      // Share quote action
                      _toggleFab();
                    },
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'favorite',
                    mini: true,
                    child: const Icon(Icons.favorite),
                    onPressed: () {
                      // Favorite quote action
                      _toggleFab();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton(
                  heroTag: 'main',
                  onPressed: _toggleFab,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);

      final results = widget.searchBookmarksOnly
          ? await isarService.searchBookmarkedQuotes(query)
          : await isarService.searchAllQuotes(query);

      // Sort results to prioritize author matches
      results.sort((a, b) {
        final aIsAuthorMatch = (a.author.value?.name ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
        final bIsAuthorMatch = (b.author.value?.name ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());

        if (aIsAuthorMatch && !bIsAuthorMatch) return -1;
        if (!aIsAuthorMatch && bIsAuthorMatch) return 1;
        return 0;
      });

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() => isLoading = false);
    }
  }
}

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
