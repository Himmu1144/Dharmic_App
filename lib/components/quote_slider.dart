import 'package:dharmic/components/custom_page_indicator.dart';
import 'package:dharmic/components/floating_buttons.dart';
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
  final Function(int)? onPageChanged; // Add this

  const QuoteSlider({
    super.key,
    required this.quotes,
    required this.initialIndex,
    this.searchQuery,
    this.onPageChanged, // Add this
  });

  @override
  State<QuoteSlider> createState() => _QuoteSliderState();
}

class _QuoteSliderState extends State<QuoteSlider>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  final Map<int, double> _authorOpacities = {};
  final Map<int, double> _quoteOpacities = {};
  int _currentPage = 0; // Make sure this is here

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    _resetOpacityForPage(widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            pageSnapping: true,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _resetOpacityForPage(index);
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.quotes.length,
            itemBuilder: (context, index) {
              final quote = widget.quotes[index];
              return _buildQuoteCard(quote, index);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: CustomPageIndicator(
              totalPages: widget.quotes.length,
              currentPage: _currentPage,
              activeColor: const Color(0xFFfa5620),
              inactiveColor: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingButtons(
        quote: widget.quotes[_currentPage],
        quotes: widget.quotes,
        currentIndex: _currentPage,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                    quote.author.value?.image ?? 'assets/images/buddha.png',
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
                      quote.author.value?.name ?? 'Buddha',
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
}
