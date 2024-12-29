import 'package:dharmic/components/quote_slider.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'quote_slider_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

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
          decoration: const InputDecoration(
            hintText: "What's on your mind today?",
            hintStyle: TextStyle(color: Colors.grey),
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
                          horizontal: 16.0, vertical: 8.0),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: searchResults!.length,
                        itemBuilder: (context, index) {
                          final quote = searchResults![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuoteSlider(
                                    quotes: searchResults!,
                                    initialIndex: index,
                                    searchQuery: _searchController
                                        .text, // Pass the search query here
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
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
                                              quote.author,
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
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animation,
                  ),
                  onPressed: _toggleFab,
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
      final isar = await isarService.db;

      // Search for both author names and quote content
      final results = await isar.quotes
          .filter()
          .group((q) => q
              .authorContains(query, caseSensitive: false)
              .or()
              .quoteContains(query, caseSensitive: false))
          .findAll();

      // Sort results to prioritize author matches
      results.sort((a, b) {
        final aIsAuthorMatch =
            a.author.toLowerCase().contains(query.toLowerCase());
        final bIsAuthorMatch =
            b.author.toLowerCase().contains(query.toLowerCase());

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
