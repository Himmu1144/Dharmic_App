import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget _buildVersionTile({
    required String version,
    required String date,
    required List<String> initialPoints,
    required List<String> expandedPoints,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        title: Text(
          'Version $version',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Released on $date',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...initialPoints.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(color: Colors.white)),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (expandedPoints.isNotEmpty) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  ...expandedPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: Colors.white70)),
                            Expanded(
                              child: Text(
                                point,
                                style:
                                    GoogleFonts.roboto(color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.roboto(fontSize: 18)),
        backgroundColor: const Color(0xFF282828),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // _buildVersionTile(
          //   version: '1.2.0',
          //   date: 'March 15, 2024',
          //   initialPoints: [
          //     'Added dark mode support across all screens',
          //     'Introduced new meditation timer feature'
          //   ],
          //   expandedPoints: [
          //     'Improved app performance and reduced load times',
          //     'Fixed various UI bugs and glitches',
          //     'Added haptic feedback for better user experience'
          //   ],
          // ),
          // _buildVersionTile(
          //   version: '1.1.0',
          //   date: 'February 1, 2024',
          //   initialPoints: [
          //     'Integrated Razorpay payment gateway',
          //     'Added bookmark synchronization'
          //   ],
          //   expandedPoints: [
          //     'Enhanced search functionality',
          //     'Added share quote feature',
          //     'Implemented offline mode support'
          //   ],
          // ),
          _buildVersionTile(
            version: '1.0.0',
            date: 'January 1, 2024',
            initialPoints: [
              'Initial release of Sanatan App',
              'Basic quote browsing functionality'
            ],
            expandedPoints: [
              'Quote categorization by author',
              'Basic search functionality',
              'Bookmark favorite quotes',
              'Simple UI with smooth animations'
            ],
          ),
        ],
      ),
    );
  }
}
