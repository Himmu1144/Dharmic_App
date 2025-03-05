import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/components/quotefullscreenpage.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dharmic/services/notification_service.dart'; // Add this import
import '../components/circle_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // // Add this static helper to access the state.
  // static _HomePageState? of(BuildContext context) =>
  //     context.findAncestorStateOfType<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late FlutterTts flutterTts;
  IconData speakIcon = Icons.play_arrow; // New variable
  List<Quote> unreadQuotes = [];
  List<Quote> viewedQuotes = [];
  int currentIndex = -1;
  bool isLoading = false;
  bool isSpeaking = false;

  // Add opacity maps for both sections
  final Map<int, double> _authorOpacities = {};
  final Map<int, double> _quoteOpacities = {};

  // Add new instance variables
  late NotificationService notificationService;
  Quote? notificationQuote;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Combine initialization in a single addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize IsarService and FlutterTts
      final isarService = Provider.of<IsarService>(context, listen: false);
      flutterTts = isarService.flutterTts;

      // Initialize notification service
      notificationService = NotificationService(context: context);
      await notificationService.initNotification();
      final hasPermission = await notificationService.requestPermissions();

      if (hasPermission) {
        await _scheduleQuoteNotifications();
      } else {
        print('Notification permission not granted');
      }

      // Load quotes after initialization
      _loadUnreadQuotes();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _resetOpacityForPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  // void refreshQuotes() {
  //   _loadUnreadQuotes();
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final newLang = Provider.of<IsarService>(context).getSelectedLanguage();
  //   newLang.then((lang) {
  //     // If the language changed, re-fetch quotes.
  //     _loadUnreadQuotes();
  //   });
  // }

  Future<void> _markAsRead(Quote quote) async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    await isarService.markQuoteAsRead(quote);
    print("Marking quote as read: ${quote.id}");
  }

  Future<void> _loadUnreadQuotes() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final quotes = await isarService.getUnreadQuotes();

      if (mounted) {
        setState(() {
          unreadQuotes = quotes..shuffle();
          if (quotes.isNotEmpty) {
            _loadNextQuote();
          }
          isLoading = false;
        });
      }
      _resetOpacityForPage(0);
    } catch (e) {
      print("Error loading unread quotes: $e");
      setState(() => isLoading = false);
    }
  }

  void _loadNextQuote() {
    if (unreadQuotes.isNotEmpty) {
      setState(() {
        viewedQuotes.add(unreadQuotes.removeAt(0));
        currentIndex = viewedQuotes.length - 1;
      });
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
                      quote.author.value?.name ?? 'Unnown',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      quote.author.value?.title ?? 'Unnown',
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
                        color: const Color.fromARGB(225, 255, 255, 255),
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
          _buildActionButtons(quote),
        ],
      ),
    );
  }

  void _shareQuote(Quote quote) {
    Share.share(
        '"${quote.quote}"\n\n- ${quote.author.value?.name ?? 'Unknown'}');
  }

  Widget _buildActionButtons(Quote quote) {
    return Consumer<IsarService>(
      builder: (context, isarService, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleButton(
                icon: isarService.speakIcon,
                isActive: isarService.isSpeaking,
                onPressed: () =>
                    isarService.handleSpeech(quote.quote, quote.language),
              ),
              //   onPressed: () =>
              //       isarService.handleSpeech(quote.quote, quote.language),
              // ),
              CircleButton(
                icon: Icons.language,
                onPressed: () {
                  // Website navigation implementation
                },
              ),
              CircleButton(
                icon: Icons.share,
                onPressed: () => _shareQuote(quote),
              ),
              CircleButton(
                icon:
                    quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                isActive: quote.isBookmarked,
                onPressed: () => isarService.toggleBookmark(quote),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scheduleQuoteNotifications() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final quote = await isarService.getRandomUnreadQuote();
    if (quote != null) {
      await notificationService.scheduleQuoteNotifications(quote);
    }
  }

  void handleNotificationTap(Quote quote) async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final index = await isarService.findQuoteIndex(quote);
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
                child: Text('Home', style: TextStyle(fontSize: 18.0))),

            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuoteFullscreenPage(
                      quotes: viewedQuotes,
                      initialIndex: currentIndex,
                      isFromHomePage: true, // Add this
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          _pageController.jumpToPage(index);

                          // Load next quote if needed
                          if (index > currentIndex) {
                            if (currentIndex >= 0) {
                              _markAsRead(viewedQuotes[currentIndex]);
                            }
                            _loadNextQuote();
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            // Update the search button navigation
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
                _resetOpacityForPage(index);
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
                return _buildQuoteCard(viewedQuotes[index], index);
              },
            ),
    );
  }
}
