import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/components/circle_button.dart';
import 'package:dharmic/components/floating_buttons.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/components/reveal_text.dart';

class QuoteFullscreenPage extends StatefulWidget {
  final List<Quote> quotes;
  final int initialIndex;
  final Function(int) onPageChanged;
  final bool isFromHomePage; // Add this

  const QuoteFullscreenPage({
    super.key,
    required this.quotes,
    required this.initialIndex,
    required this.onPageChanged,
    this.isFromHomePage = false, // Default to false
  });

  @override
  State<QuoteFullscreenPage> createState() => _QuoteFullscreenPageState();
}

class _QuoteFullscreenPageState extends State<QuoteFullscreenPage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  Future<void> _loadMoreQuotes(int currentIndex) async {
    // Only load more quotes if we're coming from HomePage
    if (!widget.isFromHomePage) return;

    if (!_isLoading && currentIndex >= widget.quotes.length - 3) {
      setState(() => _isLoading = true);

      await Provider.of<IsarService>(context, listen: false)
          .loadNextQuotes(widget.quotes);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    // Initialize controller with correct initial page
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) async {
              setState(() => _currentPage = index);
              // Notify parent about page change
              widget.onPageChanged(index); // This syncs with HomePage

              // Mark quote as read
              final isarService =
                  Provider.of<IsarService>(context, listen: false);
              final quote = widget.quotes[index];
              if (!quote.isRead) {
                final isar = await isarService.isar;
                quote.isRead = true;
                await isar.writeTxn(() async {
                  await isar.quotes.put(quote);
                });
                print("Marking quote as read in fullscreen: ${quote.id}");
              }

              await _loadMoreQuotes(index);
            },
            itemCount: widget.quotes.length,
            itemBuilder: (context, index) {
              final quote = widget.quotes[index];
              return SafeArea(
                child: SingleChildScrollView(
                  // Add this
                  physics:
                      const BouncingScrollPhysics(), // Add smooth scrolling
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60.0,
                      bottom:
                          80.0, // Increased bottom padding to avoid floating buttons
                      right: 24,
                      left: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Quote Icon
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 48,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 32),
                        // Quote Text
                        RevealText(
                          text: '\u201C ${quote.quote} \u201D',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Author Name
                        RevealText(
                          text: "- ${quote.author.value?.name ?? 'Unknown'}",
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: CircleButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingButtons(
              quote: widget.quotes[_currentPage],
              quotes: widget.quotes,
              currentIndex: _currentPage,
            ),
          ),
        ],
      ),
    );
  }
}
