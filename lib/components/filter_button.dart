import 'package:flutter/material.dart';

class HoverableFilterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const HoverableFilterButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  _HoverableFilterButtonState createState() => _HoverableFilterButtonState();
}

class _HoverableFilterButtonState extends State<HoverableFilterButton> {
  bool isHovered = false;
  bool isPressed = false;
  bool isClickEffect = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            isHovered = hovering;
          });
        },
        onHighlightChanged: (highlight) {
          setState(() {
            isPressed = highlight;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: (isHovered || isPressed || isClickEffect || widget.isActive)
                ? const Color(0xFFfa5620)
                : Colors.grey[400],
          ),
          child: Row(
            children: [
              Icon(widget.icon),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          ),
        ),
      ),
    );
  }
}
