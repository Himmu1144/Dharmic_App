import 'package:dharmic/components/my_drawer.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> printQuotes() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final isar = await isarService.db;

    final quotes = await isar.quotes.where().limit(5).findAll();

    for (var quote in quotes) {
      print(
          'Quote: ${quote.quote}, Author: ${quote.author}, IsRead: ${quote.isRead}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(child: Text('Home')),
            // IconButton(
            //   icon: const Icon(Icons.search),
            //   onPressed: () {
            //     // Navigate to search screen
            //   }, ),
            IconButton(
              icon: const Icon(Icons.bug_report), // Add a debug icon
              onPressed: () {
                printQuotes(); // Call the debug function on button press
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(80.0),
                  child: Image.asset(
                    'assets/images/marcus_aurelius.jpeg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16.0),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marcus Aurelius',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Roman Emperor',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      Divider(), // Add this line to insert a divider
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '"In no great while you will be no one and nowhere, nor will any of the things exist which you now see, nor any of those who are now living. For all things are formed by nature to change and be turned and to perish in order that other things in their turn may exist."',
              style: TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
              ),
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
