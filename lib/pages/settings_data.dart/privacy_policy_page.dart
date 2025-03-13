import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        title: Text('Privacy Policy', style: GoogleFonts.roboto(fontSize: 18)),
        backgroundColor: const Color(0xFF282828),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: January 25, 2025',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            _buildParagraph(
              'Himanshu Sharma built the The Sanatan App, as a Free app. This SERVICE is provided by Himanshu Sharma at no cost and is intended for use as is.',
            ),
            _buildParagraph(
              'This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.',
            ),
            _buildParagraph(
              'If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.',
            ),
            _buildParagraph(
              'The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at The Sanatan App unless otherwise defined in this Privacy Policy.',
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
            _buildHeading('Log Data'),
            _buildParagraph(
              'I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol ("IP") address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.',
            ),
            _buildHeading('Cookies'),
            _buildParagraph(
              'Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.\n\nThis Service does not use these "cookies" explicitly. However, the app may use third party code and libraries that use "cookies" to collect information and improve their services.',
            ),
            _buildParagraph(
              'This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.',
            ),
            _buildHeading('Service Providers'),
            _buildParagraph(
              'I may employ third-party companies and individuals due to the following reasons:',
            ),
            _buildParagraph(
              'To facilitate our Service; To provide the Service on our behalf; To perform Service-related services; or To assist us in analyzing how our Service is used. I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.',
            ),
            _buildHeading('Security'),
            _buildParagraph(
              'I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.',
            ),
            _buildHeading('Link\'s to Other Sites'),
            _buildParagraph(
              'This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.',
            ),
            _buildHeading('Children\'s Privacy'),
            _buildParagraph(
              'These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13 years of age. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions.',
            ),
            _buildHeading('Changes to This Privacy Policy'),
            _buildParagraph(
              'I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            _buildHeading('Contact Us'),
            _buildParagraph(
              'If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at:',
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
