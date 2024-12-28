import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'circle_button.dart';
import '../models/quote.dart';
import '../services/isar_service.dart';

class ActionButtons extends StatelessWidget {
  final Quote quote;
  final IconData speakIcon;
  final bool isSpeaking;
  final Function(String) onSpeak;
  final Function(Quote) onShare;

  const ActionButtons({
    super.key,
    required this.quote,
    required this.speakIcon,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleButton(
            icon: speakIcon,
            isActive: isSpeaking,
            onPressed: () => onSpeak(quote.quote),
          ),
          CircleButton(
            icon: Icons.language,
            onPressed: () {
              // Website navigation implementation
            },
          ),
          CircleButton(
            icon: Icons.share,
            onPressed: () => onShare(quote),
          ),
          Consumer<IsarService>(
            builder: (context, isarService, child) {
              return CircleButton(
                icon:
                    quote.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                isActive: quote.isBookmarked,
                onPressed: () => isarService.toggleBookmark(quote),
              );
            },
          ),
        ],
      ),
    );
  }
}
