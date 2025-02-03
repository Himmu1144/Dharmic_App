import 'package:dharmic/pages/settings_data.dart/about_page.dart';
import 'package:dharmic/pages/settings_data.dart/privacy_policy_page.dart';
import 'package:dharmic/pages/settings_data.dart/terms_page.dart';
import 'package:dharmic/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dharmic/pages/amount_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:dharmic/services/notification_service.dart';
// import 'package:dharmic/services/isar_service.dart';

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

  Widget _buildSectionWithIcon(
    BuildContext context, {
    required String heading,
    required String description,
    required IconData icon,
    required String url,
    bool showBottomDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final Uri uri = Uri.parse(url);
            try {
              if (!await launchUrl(uri)) {
                throw Exception('Could not launch $url');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open link'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   color: Colors.grey[600],
                //   size: 16,
                // ),
              ],
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
                      color: Colors.white,
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
                    'If you really like The Sanatan App, you can support me by buying me a coffee ☕. It will really help me to spread awarness about our beautiful Sanatan Dharma.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmountSelectionPage(),
                    ),
                  );
                },
                showTopDivider: false,
                showBottomDivider: true),
            // _buildSection(
            //     heading: 'Notifications',
            //     description: 'Configure your notification preferences',
            //     onTap: () {
            //       /* TODO: Implement notification settings */
            //     },
            //     showTopDivider: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 25, 0),
              child: Row(
                children: [
                  Text(
                    'Developer',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFFfa5620),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionWithIcon(
              context,
              heading: 'Instagram',
              description: '@Himmu1144',
              icon: FontAwesomeIcons.instagram, // or any other icon
              url: 'https://www.instagram.com/himmu1144/',
              showBottomDivider: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 25, 0),
              child: Row(
                children: [
                  Text(
                    'Quote',
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
              heading: 'Test Notifications',
              description: 'Send a test notification',
              onTap: () async {
                final notificationService =
                    NotificationService(context: context);
                await notificationService.initNotification();
                await notificationService.showTestNotification();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              showTopDivider: false,
            ),
            _buildSection(
                heading: 'Select Author',
                description:
                    'Choose the author\'s whose quotes you want to see',
                onTap: () {},
                showTopDivider: false,
                showBottomDivider: true),
            // _buildSection(
            //   heading: 'Daily Notifications',
            //   description: 'Set daily quote notification time',
            //   onTap: () async {
            //     TimeOfDay? selectedTime = await showTimePicker(
            //       context: context,
            //       initialTime: TimeOfDay.now(),
            //     );

            //     if (selectedTime != null) {
            //       await NotificationService().scheduleQuoteNotification(
            //         time: selectedTime,
            //         enabled: true,
            //       );

            //       // Show confirmation
            //       if (context.mounted) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //               content: Text(
            //                   'Daily notification set for ${selectedTime.format(context)}')),
            //         );
            //       }
            //     }
            //   },
            //   showTopDivider: false,
            // ),
            _buildSection(
              heading: 'Report Bug',
              description: 'Report bugs or request new features',
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'Himmu5056@gmail.com',
                    query: 'subject=Bug/Feature Report - The Sanatan App');

                try {
                  if (!await launchUrl(emailLaunchUri)) {
                    throw Exception('Could not launch email client');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open email client'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              showTopDivider: false,
            ),
            _buildSection(
              heading: 'App Version',
              description: 'Version 1.0.0',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
              showTopDivider: false,
            ),
            // _buildSection(
            //   heading: 'App Version',
            //   description: 'Version 1.0.0',
            //   onTap: () {/* TODO: Implement version info */},
            //   showTopDivider: false,
            // ),
            _buildSection(
              heading: 'Privacy Policy',
              description: 'Read our privacy policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                );
              },
              showTopDivider: false,
            ),
            _buildSection(
              heading: 'Terms Of Service',
              description: 'Read our Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsPage()),
                );
              },
              showTopDivider: false,
              showBottomDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
