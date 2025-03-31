import 'dart:io';

import 'package:dharmic/components/SafeImage.dart';
import 'package:dharmic/components/error_boundary_widget.dart';
import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/components/quotefullscreenpage.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dharmic/services/notification_service.dart'; // Add this import
import '../components/circle_button.dart';
import 'package:dharmic/models/author.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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

  // Add this method to HomePage
  void navigateToQuoteIndex(Quote quote) async {
    // Find index without database transaction
    final index = viewedQuotes.indexWhere((q) => q.id == quote.id);
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Quote not in viewed quotes, add it
      setState(() {
        viewedQuotes.add(quote);
        currentIndex = viewedQuotes.length - 1;
      });
      _pageController.animateToPage(
        viewedQuotes.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAuthorInfo(BuildContext context, Author author) {
    showModalBottomSheet(
      context: context,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        author.title,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SafeImage(
                  imagePath: author.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Short Biography',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  author.description,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
    );
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
    // print("Marking quote as read: ${quote.id}");
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
            // Add initial quote to viewedQuotes
            viewedQuotes.add(unreadQuotes.removeAt(0));
            currentIndex = 0;
          }
          isLoading = false;
        });
        _resetOpacityForPage(0);
      }
    } catch (e) {
      // print("Error loading unread quotes: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
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

    // Safe text and author handling
    final displayText =
        quote.quote.isNotEmpty ? quote.quote : "No quote available";

    // Wrap the main content in an error boundary
    return ErrorBoundaryWidget(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author section
          // Modify the AnimatedOpacity section in _buildQuoteCard method:

// Author section
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500), // Reduced duration
            opacity: _authorOpacities[index] ?? 0.0,
            curve: Curves.easeIn,
            child: GestureDetector(
              onTap: () {
                if (quote.author.value != null) {
                  _showAuthorInfo(context, quote.author.value!);
                }
              },
              child: Row(
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(80.0),
                  //   child: Image.asset(
                  //     quote.author.value?.image ?? 'assets/images/buddha.png',
                  //     width: 65,
                  //     height: 65,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),

                  // After:
                  SafeImage(
                    imagePath:
                        quote.author.value?.image ?? 'assets/images/buddha.png',
                    fallbackImagePath: 'assets/images/buddha.png',
                    width: 65,
                    height: 65,
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.6, // Constrain width
                        child: Text(
                          quote.author.value?.name ?? 'Unknown',
                          style: GoogleFonts.notoSansJp(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // Allow up to 2 lines before ellipsis
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.6, // Same width constraint
                        child: Text(
                          quote.author.value?.title ?? 'Spiritual Leader',
                          style: GoogleFonts.notoSansJp(
                            fontSize: 13.0,
                            color: Colors.grey.shade400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // Allow up to 2 lines before ellipsis
                        ),
                      ),
                      const SizedBox(height: 8.0),
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
                    "\u201C$displayText\u201D",
                    style: GoogleFonts.notoSerif(
                        color: const Color.fromARGB(225, 255, 255, 255),
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
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
    ));
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
              // Replace the existing snackbar code with this:

              CircleButton(
                icon: Icons.copy,
                onPressed: () {
                  final formattedQuote =
                      "${quote.quote}\n    ~ ${quote.author.value?.name ?? 'Unknown'}";
                  Clipboard.setData(ClipboardData(text: formattedQuote));

                  // Show an enhanced snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A3A3A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 48),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   'Success',
                                      //   style: GoogleFonts.roboto(
                                      //     fontSize: 16,
                                      //     color: Colors.white,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      // const SizedBox(height: 4),
                                      Text(
                                        'Quote copied to clipboard',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: -10,
                            top: -10,
                            child: CircleAvatar(
                              backgroundColor: Colors.green[600],
                              radius: 18,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -5,
                            top: -5,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF282828),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                      behavior: SnackBarBehavior.floating,
                      elevation: 0,
                    ),
                  );
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
    final quote = await isarService.getRandomUnreadQuoteNotif();
    if (quote != null) {
      await notificationService.scheduleQuoteNotifications(quote);
      await isarService.markQuoteAsRead(quote);
    } else {
      print('No quotes available for notifications');
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
