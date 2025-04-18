import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 15,
          height: 1.5,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points
            .map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.grey[300])),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title:
            Text('Terms & Conditions', style: GoogleFonts.roboto(fontSize: 18)),
        backgroundColor: const Color(0xFF282828),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: March 25, 2025',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            _buildParagraph(
              'By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to The Sanatana App',
            ),
            _buildParagraph(
              'We are committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.',
            ),
            _buildParagraph(
              'The Sanatana app stores and processes personal data that you have provided to us, in order to provide my Service. It’s your responsibility to keep your phone and access to the app secure. We, therefore, recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that The Sanatana app won’t work properly or at all.',
            ),
            _buildParagraph(
              'The app does use third party services that declare their own Terms and Conditions.',
            ),
            _buildHeading('Information Collection and Use'),
            _buildParagraph(
              'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information. The information that I request will be retained on your device and is not collected by me in any way.',
            ),
            _buildParagraph(
              'The app does use third party services that may collect information used to identify you.',
            ),
            _buildHeading('Third Party Service Providers'),
            _buildBulletPoints([
              'Google Play Services',
              'AdMob',
              'Google Analytics for Firebase',
              'Firebase Crashlytics',
              'Fabric',
              'Log Data',
              'Google AI Studio',
            ]),
            _buildParagraph(
              'You should be aware that there are certain things that The Sanatana App will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Infinity Labs 42 cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.',
            ),
            _buildParagraph(
              'If you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.',
            ),
            _buildParagraph(
              'Along the same lines, The Sanatana App cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, The Sanatana App  cannot accept responsibility.',
            ),
            _buildParagraph(
              'With respect to The Sanatana App’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. The Sanatana App  accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.',
            ),
            _buildParagraph(
              'At some point, we may wish to update the app. The app is currently available on Android – the requirements for system(and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. The Sanatana App does not promise that it will always update the app so that it is relevant to you and/or works with the Android version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.',
            ),
            _buildHeading('Changes to This Terms and Conditions'),
            _buildParagraph(
              'I may update our Terms and Conditions from time to time. Thus, you are advised to review this page - https://sites.google.com/view/thesanatana/terms-conditions periodically for any changes. I will notify you of any changes by posting the new Terms and Conditions on this page (https://sites.google.com/view/thesanatana/terms-conditions).',
            ),
            _buildHeading('Contact Us'),
            _buildParagraph(
              'If you have any questions or suggestions about my Privacy Policy (https://sites.google.com/view/thesanatana/privacy-policy), do not hesitate to contact me at:',
            ),
            TextButton(
              onPressed: () async {
                final Uri emailUri = Uri.parse('mailto:Himmu5056@gmail.com');
                try {
                  if (!await launchUrl(emailUri)) {
                    throw Exception('Could not launch email');
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open email client'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Himmu5056@gmail.com',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFFfa5620),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
