import 'package:dharmic/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import 'package:provider/provider.dart';
import '../services/isar_service.dart';
import 'package:share_plus/share_plus.dart';
import 'circle_button.dart'; // Update import

class QuoteSlider extends StatefulWidget {
  final List<Quote> quotes;
  final int initialIndex;
  final String? searchQuery; // Add this

  const QuoteSlider({
    Key? key,
    required this.quotes,
    required this.initialIndex,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<QuoteSlider> createState() => _QuoteSliderState();
}

class _QuoteSliderState extends State<QuoteSlider> {
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.searchQuery != null
            ? Text('Search: ${widget.searchQuery}',
                style: const TextStyle(fontSize: 18))
            : const Text('Quotes'),
        actions: [
          Consumer<IsarService>(
            builder: (context, isarService, child) {
              return IconButton(
                icon: Icon(widget
                        .quotes[_pageController.page?.round() ??
                            widget.initialIndex]
                        .isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border),
                onPressed: () async {
                  final currentQuote = widget.quotes[
                      _pageController.page?.round() ?? widget.initialIndex];
                  await isarService.toggleBookmark(currentQuote);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              SlidePageRoute(page: const SearchPage()),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        pageSnapping: true,
        onPageChanged: _resetOpacityForPage,
        itemCount: widget.quotes.length,
        itemBuilder: (context, index) {
          final quote = widget.quotes[index];
          return _buildQuoteCard(quote, index);
        },
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote, int index) {
    _authorOpacities.putIfAbsent(index, () => 0.0);
    _quoteOpacities.putIfAbsent(index, () => 0.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
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
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _quoteOpacities[index] ?? 0.0,
              curve: Curves.easeIn,
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    "\u201C${quote.quote}\u201D",
                    style: GoogleFonts.notoSerif(
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          _buildActionButtons(quote),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Quote quote) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleButton(
            icon: speakIcon,
            isActive: isSpeaking,
            onPressed: () => _handleSpeech(quote.quote),
          ),
          CircleButton(
            icon: Icons.language,
            onPressed: () {
              // Website navigation implementation
            },
          ),
          CircleButton(
            icon: Icons.share,
            onPressed: () => Share.share(quote.quote),
          ),
          Consumer<IsarService>(
            builder: (context, isarService, child) {
              return CircleButton(
                icon:
                    quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                isActive: quote.isBookmarked,
                onPressed: () => isarService.toggleBookmark(quote),
              );
            },
          ),
        ],
      ),
    );
  }
}