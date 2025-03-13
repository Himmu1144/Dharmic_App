import 'package:dharmic/components/bookmark_slide.dart';
import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
// Add this import
// Add this import
// Add this import
// Add this import
import 'package:dharmic/components/custom_page_indicator.dart';
import 'package:dharmic/components/floating_buttons.dart';
import 'package:dharmic/pages/search_page.dart';

class BookmarkSliderPage extends StatefulWidget {
  final List<Quote> bookmarkedQuotes;
  final int initialIndex;

  const BookmarkSliderPage({
    super.key,
    required this.bookmarkedQuotes,
    required this.initialIndex,
  });

  @override
  State<BookmarkSliderPage> createState() => _BookmarkSliderPageState();
}

class _BookmarkSliderPageState extends State<BookmarkSliderPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  IconData speakIcon = Icons.play_arrow;
  late AnimationController _popController;
  bool _isExpanded = false;
  late final List<AnimationController> _buttonControllers = List.generate(
    4,
    (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ),
  );
  final _buttonDelay = const Duration(milliseconds: 200); // Increased delay
  int _currentPage = 0; // Add this
  late final AnimationController _rotationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _rotationAnimation = Tween<double>(
    begin: 0,
    end: 1.0 / 4, // Changed to 1/4 turn = 90 degrees instead of 1/8 turn
  ).animate(
    CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ),
  );
  static const _maxVisibleDots = 7; // Increased for better visual balance

  late final AnimationController _dotsAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _dotsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    flutterTts = FlutterTts();

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        speakIcon = Icons.play_arrow;
      });
    });

    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dotsSlideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _dotsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    for (var controller in _buttonControllers) {
      controller.dispose();
    }
    _rotationController.dispose();
    _popController.dispose();
    _pageController.dispose();
    flutterTts.stop();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  // Future<void> _handleSpeech(String text) async {
  //   if (isSpeaking) {
  //     await flutterTts.stop();
  //     setState(() {
  //       isSpeaking = false;
  //       speakIcon = Icons.play_arrow;
  //     });
  //   } else {
  //     setState(() {
  //       isSpeaking = true;
  //       speakIcon = Icons.stop;
  //     });
  //     await flutterTts.speak(text);
  //   }
  // }

  // Future<void> _handleBookmarkToggle(Quote quote) async {
  //   final isarService = Provider.of<IsarService>(context, listen: false);
  //   await isarService.toggleBookmark(quote);
  //   // Force rebuild to show updated bookmark state
  //   setState(() {});
  // }

  // void _toggleMenu() {
  //   setState(() => _isExpanded = !_isExpanded);
  //   if (_isExpanded) {
  //     _rotationController.forward();
  //     // Forward animation - keep original timing
  //     for (var i = 0; i < _buttonControllers.length; i++) {
  //       Future.delayed(_buttonDelay * i, () {
  //         if (mounted) {
  //           _buttonControllers[i].forward();
  //         }
  //       });
  //     }
  //   } else {
  //     _rotationController.reverse();
  //     // Reverse animation - faster timing
  //     const fastReverseDelay =
  //         Duration(milliseconds: 50); // Faster reverse delay
  //     for (var i = _buttonControllers.length - 1; i >= 0; i--) {
  //       Future.delayed(fastReverseDelay * (_buttonControllers.length - 1 - i),
  //           () {
  //         if (mounted) {
  //           _buttonControllers[i].reverse(from: 1.0);
  //         }
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quote ${_currentPage + 1}/${widget.bookmarkedQuotes.length}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Consumer<IsarService>(
            builder: (context, isarService, child) {
              final currentQuote = widget.bookmarkedQuotes[_currentPage];
              return IconButton(
                icon: Icon(
                  currentQuote.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: () async {
                  await isarService.toggleBookmark(currentQuote);
                  setState(() {});
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BookmarkSlide(
            quotes: widget.bookmarkedQuotes,
            initialIndex: widget.initialIndex,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: _buildPaginationDots(),
          ),
        ],
      ),
      floatingActionButton: FloatingButtons(
        quote: widget.bookmarkedQuotes[_currentPage],
        quotes: widget.bookmarkedQuotes,
        currentIndex: _currentPage,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPaginationDots() {
    return CustomPageIndicator(
      totalPages: widget.bookmarkedQuotes.length,
      currentPage: _currentPage,
    );
  }
}
