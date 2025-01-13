import 'package:dharmic/pages/upi_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dharmic/components/amount_selection_dialog.dart';
import 'package:dharmic/pages/amount_selection_page.dart';

class SwastikaPainter extends CustomPainter {
  final Color color;

  SwastikaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double unit = size.width / 5;

    // Draw horizontal line
    canvas.drawLine(Offset(unit, size.height / 2),
        Offset(size.width - unit, size.height / 2), paint);
    // Draw vertical line
    canvas.drawLine(Offset(size.width / 2, unit),
        Offset(size.width / 2, size.height - unit), paint);

    // Draw the four bends
    // Top right
    canvas.drawLine(
        Offset(size.width / 2, unit), Offset(size.width - unit, unit), paint);
    // Bottom right
    canvas.drawLine(Offset(size.width - unit, size.height / 2),
        Offset(size.width - unit, size.height - unit), paint);
    // Bottom left
    canvas.drawLine(Offset(size.width / 2, size.height - unit),
        Offset(unit, size.height - unit), paint);
    // Top left
    canvas.drawLine(Offset(unit, size.height / 2), Offset(unit, unit), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSection({
    required String heading,
    required String description,
    required VoidCallback onTap,
    bool showTopDivider = true,
    bool showBottomDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTopDivider)
          Divider(
            color: Colors.grey.shade800,
            thickness: 1.0,
            height: 1.0,
          ),
        Material(
          // Wrap with Material for better ink effect
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              // Add Container for full width
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showBottomDivider)
          const Divider(
            color: Color.fromARGB(255, 36, 36, 36),
            thickness: 1.2,
            height: 1.0,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.roboto(fontSize: 18)),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: SwastikaPainter(const Color(0xFFfa5620)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sanatan Dharma',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFFfa5620),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              heading: 'Support Development',
              description:
                  'If you really like The Sanatan App, you can support me by buying me a coffee ☕. When i say it will help me, you can bet it really will, because yeah i am dirt poor 😭 (For now at least 😉)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AmountSelectionPage(),
                  ),
                );
              },
              showTopDivider: false,
            ),
            _buildSection(
                heading: 'Notifications',
                description: 'Configure your notification preferences',
                onTap: () {
                  /* TODO: Implement notification settings */
                },
                showTopDivider: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                'About',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFfa5620),
                ),
              ),
            ),
            _buildSection(
              heading: 'App Version',
              description: 'Version 1.0.0',
              onTap: () {/* TODO: Implement version info */},
              showTopDivider: false,
            ),
            _buildSection(
              heading: 'Privacy Policy',
              description: 'Read our privacy policy',
              onTap: () {/* TODO: Implement privacy policy */},
              showTopDivider: false,
            ),
            _buildSection(
              heading: 'Terms of Service',
              description: 'Read our terms of service',
              onTap: () {/* TODO: Implement terms of service */},
              showBottomDivider: false,
              showTopDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
