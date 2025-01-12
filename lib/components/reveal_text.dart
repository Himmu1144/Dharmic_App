import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

class RevealText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const RevealText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<RevealText> createState() => _RevealTextState();
}

class _RevealTextState extends State<RevealText>
    with SingleTickerProviderStateMixin {
  late List<double> _opacities;
  late AnimationController _controller;
  final Random _random = Random();
  late int _groupSize;
  late int _numGroups;
  late List<double> _delays; // Add delays for each group

  @override
  void initState() {
    super.initState();
    _groupSize = 1; // Number of characters per group
    _numGroups = (widget.text.length / _groupSize).ceil();
    _opacities = List.filled(_numGroups, 0.0);
    // Create random delays for each group
    _delays = List.generate(_numGroups, (index) => _random.nextDouble() * 0.7);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Increased duration
      vsync: this,
    );

    _controller.addListener(_updateOpacities);
    _controller.forward();
  }

  void _updateOpacities() {
    setState(() {
      for (int i = 0; i < _opacities.length; i++) {
        // If animation is near end, make all text visible at white70
        if (_controller.value > 0.95) {
          _opacities[i] = 0.8; // Changed from 1.0 to 0.7
          continue;
        }

        // Normal reveal logic for earlier parts of animation
        if (_controller.value > _delays[i]) {
          if (_opacities[i] < 0.7) {
            // Changed from 1.0 to 0.7
            double targetOpacity =
                (_controller.value - _delays[i]) * 0.91; // Adjusted multiplier

            if (_random.nextDouble() < 0.2) {
              _opacities[i] =
                  targetOpacity.clamp(0.0, 0.7); // Changed clamp max to 0.7
            }
          }
        } else {
          _opacities[i] = 0.0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');
    return Text.rich(
      TextSpan(
        children: List.generate(_numGroups, (groupIndex) {
          final startIndex = groupIndex * _groupSize;
          final endIndex =
              (startIndex + _groupSize).clamp(0, characters.length);
          final groupText = characters.sublist(startIndex, endIndex).join();

          return TextSpan(
            text: groupText,
            style: GoogleFonts.niconne(
              // Use GoogleFonts here
              fontSize: widget.style.fontSize! *
                  1.5, // Make font size larger since Niconne is smaller
              color: widget.style.color?.withOpacity(
                  _opacities[groupIndex] <= 0.3 ? 0.0 : _opacities[groupIndex]),
              height:
                  1.4, // Reduced from default ~1.4 to 1.2 for tighter spacing
            ),
          );
        }),
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
