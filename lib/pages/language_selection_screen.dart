// language_selection_screen.dart
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectionScreen({Key? key, required this.onLanguageSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                '"Wisdom comes from many sources"',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.orange.shade800,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: _LanguageCard(
                      language: 'Hinglish',
                      onTap: () => onLanguageSelected('hi'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LanguageCard(
                      language: 'English',
                      onTap: () => onLanguageSelected('en'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade800),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              language,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to select',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
