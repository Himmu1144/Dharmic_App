import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
// import 'services/isar_service.dart';
// import 'models/quote.dart'; // Ensure the Quote model is imported

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Quote> unreadQuotes = []; // List to store unread quotes
  List<Quote> viewedQuotes = []; // List to store previously viewed quotes
  int currentIndex = -1; // Start with -1 to indicate no current quote

  @override
  void initState() {
    super.initState();
    _loadUnreadQuotes();
  }

  // Fetch unread quotes from Isar
  Future<void> _loadUnreadQuotes() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final isar = await isarService.db;

    // Fetch unread quotes and shuffle them
    final quotes = await isar.quotes.filter().isReadEqualTo(false).findAll();
    setState(() {
      unreadQuotes = quotes..shuffle(); // Shuffle the quotes for randomness
    });

    // If unreadQuotes is not empty, load the first quote
    if (unreadQuotes.isNotEmpty) {
      _loadNextQuote();
    }
  }

  // Load the next unread quote
  void _loadNextQuote() {
    if (unreadQuotes.isNotEmpty) {
      final nextQuote = unreadQuotes.removeAt(0);
      setState(() {
        viewedQuotes.add(nextQuote);
        currentIndex = viewedQuotes.length - 1; // Update current index
      });
    }
  }

  // Mark the current quote as read
  Future<void> _markAsRead() async {
    if (currentIndex >= 0 && !viewedQuotes[currentIndex].isRead) {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final isar = await isarService.db;

      // Mark the current quote as read
      final quote = viewedQuotes[currentIndex];
      quote.isRead = true;

      await isar.writeTxn(() async {
        await isar.quotes.put(quote); // Update the quote in the database
      });
    }
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
                // Navigate to search screen
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
      body: PageView.builder(
        controller:
            PageController(initialPage: currentIndex >= 0 ? currentIndex : 0),
        onPageChanged: (index) {
          if (index > currentIndex) {
            // Swiping right - load next quote
            _markAsRead(); // Mark the current quote as read
            _loadNextQuote(); // Load the next unread quote
          } else if (index < currentIndex && index >= 0) {
            // Swiping left - show previous quote
            setState(() {
              currentIndex = index; // Update current index
            });
          }
        },
        itemBuilder: (context, index) {
          if (index < 0 || index >= viewedQuotes.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final quote = viewedQuotes[index];
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

                // Adding the four bottom buttons here
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CircleButton(
                        icon: Icons.play_arrow,
                        onPressed: () {
                          // Play audio
                        },
                      ),
                      _CircleButton(
                        icon: Icons.language,
                        onPressed: () {
                          // Navigate to website
                        },
                      ),
                      _CircleButton(
                        icon: Icons.share,
                        onPressed: () {
                          // Share content
                        },
                      ),
                      _CircleButton(
                        icon: Icons.bookmark,
                        onPressed: () {
                          // Navigate to bookmarks
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({
    Key? key,
    required this.icon,
    required this.onPressed,
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
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
