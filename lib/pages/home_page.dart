import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isarService = Provider.of<IsarService>(context);

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
      body: Consumer<IsarService>(
        builder: (context, isarService, child) {
          // Check if quotes are loaded
          if (isarService.viewedQuotes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return PageView.builder(
            controller: PageController(
              initialPage: isarService.currentIndex,
            ),
            onPageChanged: (index) {
              if (index > isarService.currentIndex) {
                isarService.markAsRead(); // Mark current as read
                isarService.loadNextQuote(); // Load next unread
              }
            },
            itemBuilder: (context, index) {
              // Ensure the index is valid
              if (index < 0 || index >= isarService.viewedQuotes.length) {
                return const Center(child: Text("No more quotes available."));
              }

              final quote = isarService.viewedQuotes[index];
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
                            icon: quote.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            onPressed: () => isarService.toggleBookmark(quote),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
