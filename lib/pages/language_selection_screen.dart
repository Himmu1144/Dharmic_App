import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/isar_service.dart';
import 'package:rive/rive.dart' as rive;

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Animation container
                const SizedBox(
                  height: 200,
                  child: rive.RiveAnimation.asset(
                    'assets/cat_following_the_mouse.riv',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Choose Your Language',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),

                // Language Cards Row
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLanguageCard(
                          'English',
                          'The mind is endless, a field of knowledge.',
                          'en',
                          'Lord Krishna',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildLanguageCard(
                          'Hinglish',
                          'Manushya ka dimag. Gyan ka kshetra.',
                          'hi',
                          'Lord Krishna',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                // Next Button
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: selectedLanguage != null ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selectedLanguage != null
                            ? [Colors.white, Colors.white70]
                            : [Colors.grey, Colors.grey.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: selectedLanguage != null
                          ? () => _onNextPressed()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    String language,
    String quote,
    String langCode,
    String author,
  ) {
    final isSelected = selectedLanguage == langCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = langCode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  language,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 15,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              quote,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.white38,
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "* by $author",
              style: TextStyle(
                color: isSelected ? Colors.white60 : Colors.white30,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNextPressed() async {
    if (selectedLanguage == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      await isarService.setFirstLaunchComplete(selectedLanguage!);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save language selection: $e')),
      );
      setState(() => _isSaving = false);
    }
  }
}
