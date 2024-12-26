import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  late FlutterTts flutterTts;
  IconData speakIcon = Icons.play_arrow; // New variable
  List<Quote> unreadQuotes = [];
  List<Quote> viewedQuotes = [];
  int currentIndex = -1;
  bool isLoading = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    flutterTts = FlutterTts();

    // Set up TTS completion callback
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        speakIcon = Icons.play_arrow;
      });
    });

    _loadUnreadQuotes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadUnreadQuotes() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final isar = await isarService.db;

      final quotes = await isar.quotes.filter().isReadEqualTo(false).findAll();
      print("Unread quotes found: ${quotes.length}");

      if (quotes.isEmpty) {
        print("No unread quotes found. Resetting all quotes...");
        await _resetAllQuotes(isar);
        // Fetch quotes again after reset
        quotes
            .addAll(await isar.quotes.filter().isReadEqualTo(false).findAll());
        print("After reset, unread quotes: ${quotes.length}");
      }

      if (mounted) {
        setState(() {
          unreadQuotes = quotes..shuffle();
          if (unreadQuotes.isNotEmpty) {
            _loadNextQuote();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading unread quotes: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetAllQuotes(Isar isar) async {
    await isar.writeTxn(() async {
      final allQuotes = await isar.quotes.where().findAll();
      for (var quote in allQuotes) {
        quote.isRead = false;
      }
      await isar.quotes.putAll(allQuotes);
    });
  }

  void _loadNextQuote() {
    if (unreadQuotes.isNotEmpty) {
      setState(() {
        viewedQuotes.add(unreadQuotes.removeAt(0));
        currentIndex = viewedQuotes.length - 1;
      });
    }
  }

  Future<void> _markAsRead(Quote quote) async {
    if (!quote.isRead) {
      print("Marking quote as read: ${quote.id}");
      final isarService = Provider.of<IsarService>(context, listen: false);
      final isar = await isarService.db;

      quote.isRead = true;
      await isar.writeTxn(() async {
        await isar.quotes.put(quote);
      });

      isarService.updateQuotes();
    }
  }

  Future<void> _speakQuote(String text) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _shareQuote(Quote quote) async {
    try {
      final text = '${quote.quote}\n- ${quote.author}';
      await Share.share(
        text,
        subject: 'Check out this quote!',
      ).then((_) {
        print('Shared successfully');
      }).catchError((error) {
        print('Share failed: $error');
      });
    } catch (e) {
      print('Share error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share quote')),
      );
    }
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
          _CircleButton(
            icon: speakIcon,
            isActive: isSpeaking,
            onPressed: () => _handleSpeech(quote.quote),
          ),
          _CircleButton(
            icon: Icons.language,
            onPressed: () {
              // Website navigation implementation
            },
          ),
          _CircleButton(
            icon: Icons.share,
            onPressed: () {
              _shareQuote(quote);
            },
          ),
          Consumer<IsarService>(
            builder: (context, isarService, child) {
              return _CircleButton(
                icon:
                    quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                isActive: quote.isBookmarked,
                onPressed: () async {
                  await isarService.toggleBookmark(quote);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(child: Text('Home')),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search implementation
              },
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const MyDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              // Add page snapping for smooth transitions
              pageSnapping: true,
              onPageChanged: (index) {
                print(
                    "Page changed to index: $index, current index: $currentIndex");
                if (index > currentIndex) {
                  if (currentIndex >= 0) {
                    _markAsRead(viewedQuotes[currentIndex]);
                  }
                  _loadNextQuote();
                } else if (index < currentIndex && index >= 0) {
                  setState(() {
                    currentIndex = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                if (index < 0 || index >= viewedQuotes.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildQuoteCard(viewedQuotes[index]);
              },
            ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _CircleButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.amber : Colors.white,
        ),
      ),
    );
  }
}
