import 'package:dharmic/pages/settings_data.dart/about_page.dart';
import 'package:dharmic/pages/settings_data.dart/privacy_policy_page.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/pages/settings_data.dart/terms_page.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/services/notification_service.dart';
import 'package:dharmic/utils/permission_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dharmic/pages/amount_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:app_settings/app_settings.dart';

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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Add this helper method to your SettingsPage class
  Widget _buildTimeRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.grey[600], size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildLanguageRow() {
    return FutureBuilder<String>(
      future: Provider.of<IsarService>(context, listen: false)
          .getSelectedLanguage(),
      builder: (context, snapshot) {
        final currentLang = snapshot.data ?? 'en';
        final displayLang = currentLang == 'hi' ? 'Hinglish' : 'English';
        return _buildSection(
          heading: 'Preferred Language',
          description: 'Currently: $displayLang. Tap to change.',
          onTap: () async {
            // Show a dialog to select language
            final selectedLang = await showDialog<String>(
              context: context,
              builder: (context) {
                // Use a temporary variable to track selection in the dialog.
                String tempLang = currentLang;
                return AlertDialog(
                  backgroundColor: const Color(0xFF202020),
                  title: Text(
                    'Select Language',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            title: Text(
                              'English',
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                            value: 'en',
                            groupValue: tempLang,
                            onChanged: (value) {
                              setState(() {
                                tempLang = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text(
                              'Hinglish',
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                            value: 'hi',
                            groupValue: tempLang,
                            onChanged: (value) {
                              setState(() {
                                tempLang = value!;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.roboto(color: Colors.grey[400]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, tempLang);
                      },
                      child: Text(
                        'Save',
                        style:
                            GoogleFonts.roboto(color: const Color(0xFFfa5620)),
                      ),
                    ),
                  ],
                );
              },
            );
            // If the user selected a new language, update the setting.
            if (selectedLang != null && selectedLang != currentLang) {
              await Provider.of<IsarService>(context, listen: false)
                  .updateLanguage(selectedLang);
              setState(() {}); // Refresh the SettingsPage if needed.
            }
          },
        );
      },
    );
  }

  static const String MORNING_HOUR_KEY = 'morning_hour';
  static const String MORNING_MINUTE_KEY = 'morning_minute';
  static const String EVENING_HOUR_KEY = 'evening_hour';
  static const String EVENING_MINUTE_KEY = 'evening_minute';

  // Add this method to the _SettingsPageState class
  Future<String> _getStoredTimeString(String key, String defaultTime) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultTime;
  }

  Future<void> _saveTimeString(String key, String timeString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, timeString);
  }

  Future<TimeOfDay> _getStoredTime(bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    final hour =
        prefs.getInt(isMorning ? MORNING_HOUR_KEY : EVENING_HOUR_KEY) ??
            (isMorning ? 6 : 18);
    final minute =
        prefs.getInt(isMorning ? MORNING_MINUTE_KEY : EVENING_MINUTE_KEY) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Add this method to check notification permission status
  Future<bool> _checkNotificationPermissions() async {
    final notificationService = NotificationService(context: context);
    return await notificationService.requestPermissions();
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
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 20, 25, 0),
            //   child: Row(
            //     children: [
            //       Text(
            //         'Quote',
            //         style: GoogleFonts.roboto(
            //           fontSize: 16,
            //           fontWeight: FontWeight.normal,
            //           color: const Color(0xFFfa5620),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Add this after other sections in the build method
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 20, 25, 0),
            //   child: Text(
            //     'Notification',
            //     style: GoogleFonts.roboto(
            //       fontSize: 16,
            //       fontWeight: FontWeight.normal,
            //       color: const Color(0xFFfa5620),
            //     ),
            //   ),
            // ),

// In your build method, replace the existing Padding with:
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 25, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFFfa5620),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _checkNotificationPermissions(),
                    builder: (context, snapshot) {
                      final hasPermission = snapshot.data ?? false;
                      return !hasPermission
                          ? CupertinoSwitch(
                              value: snapshot.data ?? false,
                              activeColor: const Color(0xFFfa5620),
                              onChanged: (bool value) async {
                                if (value) {
                                  // Request permission if turning on
                                  final notificationService =
                                      NotificationService(context: context);
                                  await notificationService.initNotification();
                                  final granted = await notificationService
                                      .requestPermissions();
                                  if (!granted && mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const PermissionDialog(),
                                    );
                                  }
                                } else {
                                  // Cancel all notifications if turning off
                                  final notificationService =
                                      NotificationService(context: context);
                                  await notificationService
                                      .cancelAllNotifications();
                                }
                                setState(() {}); // Refresh UI
                              },
                            )
                          : const SizedBox
                              .shrink(); // Hide when permissions are true;
                    },
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FutureBuilder<TimeOfDay>(
                    future: _getStoredTime(
                        true), // true for morning, false for evening
                    builder: (context, snapshot) {
                      final time =
                          snapshot.data ?? const TimeOfDay(hour: 6, minute: 0);
                      return _buildTimeRow(
                        context: context,
                        icon: Icons.wb_sunny_outlined,
                        label: 'Morning Quote',
                        time: time.format(context),
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );

                          if (selectedTime != null) {
                            // Schedule notification with new time
                            final notificationService =
                                NotificationService(context: context);
                            await notificationService.initNotification();
                            await notificationService.scheduleQuoteNotification(
                              time: selectedTime,
                              enabled: true,
                              isMorningTime: true,
                            );

                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                  Divider(color: Colors.grey[800], height: 1),
                  // In the FutureBuilder for evening time
                  FutureBuilder<TimeOfDay>(
                    future: _getStoredTime(false), // false for evening
                    builder: (context, snapshot) {
                      final time =
                          snapshot.data ?? const TimeOfDay(hour: 18, minute: 0);
                      return _buildTimeRow(
                        context: context,
                        icon: Icons.nights_stay_outlined,
                        label: 'Evening Quote',
                        time: time.format(context),
                        onTap: () async {
                          print("Evening time selection tapped"); // Debug print
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );

                          if (selectedTime != null) {
                            print(
                                "Evening time selected: ${selectedTime.format(context)}"); // Debug print
                            final notificationService =
                                NotificationService(context: context);
                            await notificationService.initNotification();
                            await notificationService.scheduleQuoteNotification(
                              time: selectedTime,
                              enabled: true,
                              isMorningTime:
                                  false, // Make sure this is false for evening
                            );
                            setState(() {});
                          }
                        },
                      );
                    },
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

            _buildLanguageRow(),

            // In settings_page.dart, update the Select Author section:
            // _buildSection(
            //   heading: 'Select Authors',
            //   description: 'Choose the authors whose quotes you want to see',
            //   onTap: () {
            //     showDialog(
            //       context: context,
            //       builder: (context) => const AuthorSelectionDialog(),
            //     ).then((selectedAuthors) {
            //       if (selectedAuthors != null) {
            //         // Handle the selected authors
            //         print('Selected authors: $selectedAuthors');
            //       }
            //     });
            //   },
            //   showTopDivider: false,
            //   showBottomDivider: true,
            // ),

            // _buildSection(
            //   heading: 'Select Authors',
            //   description: 'Choose the authors whose quotes you want to see',
            //   onTap: () {
            //     showDialog(
            //       context: context,
            //       builder: (context) => const AuthorSelectionDialog(),
            //     ).then((selectedAuthors) {
            //       if (selectedAuthors != null) {
            //         // After saving, you may want to refresh the home page.
            //         // This could be by triggering a reload on your IsarService or by using a callback.
            //         print('Selected authors updated');
            //       }
            //     });
            //   },
            //   showTopDivider: false,
            //   showBottomDivider: true,
            // ),

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
