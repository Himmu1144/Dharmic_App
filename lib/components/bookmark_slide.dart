import 'package:dharmic/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import 'package:provider/provider.dart';
import '../services/isar_service.dart';
import 'package:share_plus/share_plus.dart';
import 'circle_button.dart'; // Update import

class BookmarkSlide extends StatefulWidget {
  final List<Quote> quotes;
  final int initialIndex;

  final Function(int)? onPageChanged; // Add this

  const BookmarkSlide({
    Key? key,
    required this.quotes,
    required this.initialIndex,
    this.onPageChanged, // Add this
  }) : super(key: key);

  @override
  State<BookmarkSlide> createState() => _BookmarkSlideState();
}

class _BookmarkSlideState extends State<BookmarkSlide>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  IconData speakIcon = Icons.play_arrow;
  Map<int, double> _authorOpacities = {};
  Map<int, double> _quoteOpacities = {};

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

    _resetOpacityForPage(widget.initialIndex);
  }

  @override
  void dispose() {
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

  void _resetOpacityForPage(int pageIndex) {
    setState(() {
      _authorOpacities[pageIndex] = 0.0;
      _quoteOpacities[pageIndex] = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _authorOpacities[pageIndex] = 1.0;
          _quoteOpacities[pageIndex] = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        pageSnapping: true,
        onPageChanged: (index) {
          _resetOpacityForPage(index);
          widget.onPageChanged?.call(index); // Add this line
        },
        itemCount: widget.quotes.length,
        itemBuilder: (context, index) {
          final quote = widget.quotes[index];
          return _buildQuoteCard(quote, index);
        },
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote, int index) {
    // Initialize opacities for new pages
    _authorOpacities.putIfAbsent(index, () => 0.0);
    _quoteOpacities.putIfAbsent(index, () => 0.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author section
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500), // Reduced duration
            opacity: _authorOpacities[index] ?? 0.0,
            curve: Curves.easeIn,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(80.0),
                  child: Image.asset(
                    quote.authorImg,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.author,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Spiritual Leader',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 13.0,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8.0), // Reduced spacing
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 2.0,
                      ),
                      width: 200.0,
                      child: Divider(
                        color: Colors.grey.shade800,
                        thickness: 2.0,
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Quote section
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500), // Reduced duration
              opacity: _quoteOpacities[index] ?? 0.0,
              curve: Curves.easeIn,
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0, left: 25, top: 10),
                child: SingleChildScrollView(
                  child: Text(
                    "\u201C${quote.quote}\u201D",
                    style: GoogleFonts.notoSerif(
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w300,
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // _buildActionButtons(quote),
        ],
      ),
    );
  }

  // Widget _buildActionButtons(Quote quote) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         CircleButton(
  //           icon: speakIcon,
  //           isActive: isSpeaking,
  //           onPressed: () => _handleSpeech(quote.quote),
  //         ),
  //         CircleButton(
  //           icon: Icons.language,
  //           onPressed: () {
  //             // Website navigation implementation
  //           },
  //         ),
  //         CircleButton(
  //           icon: Icons.share,
  //           onPressed: () => Share.share(quote.quote),
  //         ),
  //         Consumer<IsarService>(
  //           builder: (context, isarService, child) {
  //             return CircleButton(
  //               icon:
  //                   quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
  //               isActive: quote.isBookmarked,
  //               onPressed: () => isarService.toggleBookmark(quote),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
