import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/components/circle_button.dart'; // Add this import
import 'dart:ui' show lerpDouble; // Add this import

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

  @override
  void initState() {
    super.initState();
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
      _popController.forward();
    } else {
      _popController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.bookmarkedQuotes.length,
            itemBuilder: (context, index) {
              final quote = widget.bookmarkedQuotes[index];
              return _buildQuoteCard(quote);
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
        height: 200,
        width: 250,
        child: Stack(
          alignment: Alignment.bottomRight, // Changed to bottomRight
          children: [
            Positioned(
              bottom: 80,
              right: 0, // Align with main button
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0), // Start from right
                      end: const Offset(-0.2, 0), // End slightly left
                    ).animate(
                      CurvedAnimation(
                        parent: _popController,
                        curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
                        reverseCurve: Curves.easeInBack,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _popController,
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
                        child: const Text(
                          'Favorite',
                          style: TextStyle(
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
                        parent: _popController,
                        curve: Curves.easeOutBack,
                        reverseCurve: Curves.easeInBack,
                      ),
                    ),
                    child: CircleButton(
                      icon: Icons.favorite,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            CircleButton(
              icon: _isExpanded ? Icons.close : Icons.menu,
              onPressed: _toggleMenu,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Add this
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: Image.asset(
              quote.authorImg,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            quote.quote,
            style: const TextStyle(
              fontSize: 18.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '- ${quote.author}',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          // _buildActionButtons(quote),
        ],
      ),
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

//   Widget _buildActionButtons(Quote quote) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           CircleButton(
//             icon: speakIcon,
//             isActive: isSpeaking,
//             onPressed: () => _handleSpeech(quote.quote),
//           ),
//           CircleButton(
//             icon: Icons.language,
//             onPressed: () {
//               // Website navigation implementation
//             },
//           ),
//           CircleButton(
//             icon: Icons.share,
//             onPressed: () => Share.share(quote.quote),
//           ),
//           Consumer<IsarService>(
//             builder: (context, isarService, child) {
//               return CircleButton(
//                 icon:
//                     quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                 isActive: quote.isBookmarked,
//                 onPressed: () => _handleBookmarkToggle(quote),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
}
