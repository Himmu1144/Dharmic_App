import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/components/circle_button.dart';

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

class _BookmarkSliderPageState extends State<BookmarkSliderPage> {
  late PageController _pageController;
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  IconData speakIcon = Icons.play_arrow;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.bookmarkedQuotes.length,
        itemBuilder: (context, index) {
          final quote = widget.bookmarkedQuotes[index];
          return _buildQuoteCard(quote);
        },
      ),
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
                onPressed: () => _handleBookmarkToggle(quote),
              );
            },
          ),
        ],
      ),
    );
  }
}
