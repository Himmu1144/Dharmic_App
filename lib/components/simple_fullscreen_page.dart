import 'package:flutter/material.dart';
import 'package:dharmic/models/quote.dart';
import 'package:dharmic/components/circle_button.dart';
import 'package:dharmic/components/reveal_text.dart';

class SimpleFullscreenPage extends StatelessWidget {
  final Quote quote;

  const SimpleFullscreenPage({
    Key? key,
    required this.quote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60.0,
                  bottom: 80.0,
                  right: 24,
                  left: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quote Icon
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 48,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 32),
                    // Quote Text
                    RevealText(
                      text: '\u201C ${quote.quote} \u201D',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Author Name
                    RevealText(
                      text: "- ${quote.author.value?.name ?? 'Unknown'}",
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: CircleButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
