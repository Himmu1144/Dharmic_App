import 'package:dharmic/components/bookmark_slide.dart';
import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/components/circle_button.dart'; // Add this import
import 'dart:ui' show lerpDouble;
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // Add this import
import 'package:dharmic/components/quote_card.dart'; // Add this import
import 'package:dharmic/components/quote_slider.dart'; // Add this import

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
  late List<AnimationController> _buttonControllers = List.generate(
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
    super.dispose();
  }

  Future<void> _handleSpeech(String text) async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
        speakIcon = Icons.play_arrow;
      });
    } else {
      setState(() {
        isSpeaking = true;
        speakIcon = Icons.stop;
      });
      await flutterTts.speak(text);
    }
  }

  Future<void> _handleBookmarkToggle(Quote quote) async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    await isarService.toggleBookmark(quote);
    // Force rebuild to show updated bookmark state
    setState(() {});
  }

  void _toggleMenu() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _rotationController.forward();
      // Forward animation - keep original timing
      for (var i = 0; i < _buttonControllers.length; i++) {
        Future.delayed(_buttonDelay * i, () {
          if (mounted) {
            _buttonControllers[i].forward();
          }
        });
      }
    } else {
      _rotationController.reverse();
      // Reverse animation - faster timing
      final fastReverseDelay =
          const Duration(milliseconds: 50); // Faster reverse delay
      for (var i = _buttonControllers.length - 1; i >= 0; i--) {
        Future.delayed(fastReverseDelay * (_buttonControllers.length - 1 - i),
            () {
          if (mounted) {
            _buttonControllers[i].reverse(from: 1.0);
          }
        });
      }
    }
  }

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
          // Dark overlay
          if (_isExpanded)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 400, // Increased height to accommodate more buttons
        width: 250,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Update button actions
            _buildAnimatedButtonWithLabel(
              controller: _buttonControllers[3],
              label: 'Share',
              icon: Icons.share,
              offset: 320,
              onPressed: () {
                final quote = widget.bookmarkedQuotes[_currentPage];
                Share.share(quote.quote);
              },
              index: 3,
            ),
            _buildAnimatedButtonWithLabel(
              controller: _buttonControllers[2],
              label: 'Language',
              icon: Icons.language,
              offset: 240,
              onPressed: () {
                // Website navigation implementation
              },
              index: 2,
            ),
            _buildAnimatedButtonWithLabel(
              controller: _buttonControllers[1],
              label: 'Speak',
              icon: speakIcon,
              offset: 160,
              onPressed: () {
                final quote = widget.bookmarkedQuotes[_currentPage]; // Updated
                _handleSpeech(quote.quote);
              },
              index: 1,
            ),
            _buildAnimatedButtonWithLabel(
              controller: _buttonControllers[0],
              label: 'Bookmark',
              icon: widget.bookmarkedQuotes[_currentPage].isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              offset: 80,
              onPressed: () async {
                final quote = widget.bookmarkedQuotes[_currentPage];
                await _handleBookmarkToggle(quote);
              },
              index: 0,
            ),
            // Main floating action button
            RotationTransition(
              turns: _rotationAnimation,
              child: CircleButton(
                icon: Icons.edit,
                onPressed: _toggleMenu,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Add this
    );
  }

  Widget _buildAnimatedButton({
    required Animation<double> animation,
    required IconData icon,
    required Color color,
    required double offset,
    required VoidCallback onPressed,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate the source position (previous button's position)
        final double sourcePosition = index == 0 ? 0 : (offset - 75.0);
        final double pushForce = (1 - animation.value) * 30; // Stronger push

        // Calculate position based on previous button
        final double currentPosition = lerpDouble(
              sourcePosition, // Start from previous button
              offset,
              animation.value,
            )! +
            pushForce;

        // Scale effect during push
        final double scaleEffect =
            1.0 + (animation.value < 0.5 ? (1 - animation.value) * 0.2 : 0.0);

        return Positioned(
          bottom: currentPosition,
          right: 0,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                0.0,
                pushForce,
                index * (1 - animation.value) * -50, // Stack effect
              )
              ..scale(scaleEffect),
            child: Opacity(
              opacity: animation.value,
              child: CircleButton(
                icon: icon,
                onPressed: onPressed,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButtonWithLabel({
    required AnimationController controller,
    required String label,
    required IconData icon,
    required double offset,
    required VoidCallback onPressed,
    required int index,
  }) {
    return Positioned(
      bottom: offset,
      right: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: const Offset(-0.2, 0),
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
                reverseCurve: Curves.easeInBack,
              ),
            ),
            child: FadeTransition(
              opacity: controller,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          ScaleTransition(
            alignment: Alignment.center,
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInBack,
              ),
            ),
            child: Transform.scale(
              scale: 0.8, // Makes the button 80% of original size
              child: CircleButton(
                icon: icon,
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
