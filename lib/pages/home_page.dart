import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          // Author info section
          Row(
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
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade300,
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

          const SizedBox(height: 16.0),
          // Quote section
          Expanded(
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
          const SizedBox(height: 16.0),
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
        backgroundColor: const Color(0xFF282828),
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

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _CircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        )),
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFfa5620), // Hex color with alpha channel
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }
}
