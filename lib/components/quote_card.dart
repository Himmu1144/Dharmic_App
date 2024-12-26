import 'package:flutter/material.dart';
import '../models/quote.dart';
import 'action_buttons.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final IconData speakIcon;
  final bool isSpeaking;
  final Function(String) onSpeak;
  final Function(Quote) onShare;

  const QuoteCard({
    Key? key,
    required this.quote,
    required this.speakIcon,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80.0),
            child: Image.asset(
              quote.authorImg,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            quote.quote,
            style: const TextStyle(
              fontSize: 18.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '- ${quote.author}',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          ActionButtons(
            quote: quote,
            speakIcon: speakIcon,
            isSpeaking: isSpeaking,
            onSpeak: onSpeak,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}
