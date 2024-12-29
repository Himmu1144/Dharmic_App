import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward();
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        )),
        child: Container(
          width: 62.0,
          height: 62.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFfa5620),
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }
}
