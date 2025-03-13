import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  // Set this to true while debugging, false for production
  static const bool _isDebugging = true;

  Future<void> openSettings(BuildContext context) async {
    try {
      if (_isDebugging) {
        // Simple debug implementation
        await AppSettings.openAppSettings();
        return;
      }

      // Production implementation
      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        final AndroidIntent intent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:${packageInfo.packageName}',
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        // iOS specific implementation
        if (await canLaunchUrl(Uri.parse('app-settings:'))) {
          await launchUrl(
            Uri.parse('app-settings:'),
            mode: LaunchMode.externalNonBrowserApplication,
          );
        }
      }
    } catch (e) {
      // Show detailed error in debug, simple message in production
      if (_isDebugging) {
        // print('Debug Error opening settings: $e');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDebugging
                ? 'Debug Error: $e'
                : 'Unable to open settings. Please open settings manually.'),
            duration: const Duration(seconds: _isDebugging ? 5 : 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Color(0xFFfa5620),
            ),
            const SizedBox(height: 16),
            Text(
              'Notification Permissions are Denied',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable notifications in app settings.',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openSettings(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfa5620),
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Open Settings',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
