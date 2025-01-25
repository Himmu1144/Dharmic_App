import 'package:dharmic/components/author_quote_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/author.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthorSort { alphabetical, quote_count, default_order }

class AuthorPage extends StatefulWidget {
  const AuthorPage({super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  AuthorSort currentSort = AuthorSort.default_order;

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Colors.white),
              title: const Text('Alphabetical (A-Z)',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => currentSort = AuthorSort.alphabetical);
                Navigator.pop(context);
              },
              trailing: currentSort == AuthorSort.alphabetical
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.format_quote, color: Colors.white),
              title: const Text('Most Quotes',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => currentSort = AuthorSort.quote_count);
                Navigator.pop(context);
              },
              trailing: currentSort == AuthorSort.quote_count
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
            ListTile(
              leading:
                  const Icon(Icons.format_list_numbered, color: Colors.white),
              title: const Text('Default Order',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => currentSort = AuthorSort.default_order);
                Navigator.pop(context);
              },
              trailing: currentSort == AuthorSort.default_order
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(author.image),
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

  void _showAuthorQuotes(BuildContext context, Author author) async {
    final isarService = Provider.of<IsarService>(context, listen: false);

    // Fetch quotes for this author
    final quotes = await isarService.fetchQuotesByAuthor(author);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthorQuoteSlider(
            quotes: quotes,
            author: author,
            initialIndex: 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Authors', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<IsarService>(
        builder: (context, isarService, child) {
          return FutureBuilder<List<Author>>(
            future: isarService.fetchAllAuthors(sort: currentSort),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final authors = snapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: authors.length,
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => _showAuthorInfo(context, author),
                              child: Image.asset(
                                author.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => _showAuthorQuotes(context, author),
                              child: Container(
                                width: double.infinity,
                                color: const Color(0xFF434343),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        author.name,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
