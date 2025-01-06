import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  void _handleImageTap(String authorName) {
    print('Image tapped for $authorName');
    // Will handle image tap later
  }

  void _handleNameTap(String authorName) {
    print('Name tapped for $authorName');
    // Will handle name tap later
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Authors',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Consumer<IsarService>(
        builder: (context, isarService, child) {
          return FutureBuilder<List<Map<String, String>>>(
            future: isarService.fetchUniqueAuthors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No authors found'));
              }

              final authors = snapshot.data!;

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
                          // Image section with its own GestureDetector
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  _handleImageTap(authors[index]['name']!),
                              child: Image.asset(
                                authors[index]['image']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          // Name section with its own GestureDetector
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  _handleNameTap(authors[index]['name']!),
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[800],
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0,
                                        left: 16.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                    child: Text(
                                      authors[index]['name']!,
                                      textAlign: TextAlign.center, // Add this
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
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
