import 'package:flutter/material.dart';

class SafeImage extends StatelessWidget {
  final String imagePath;
  final String fallbackImagePath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SafeImage({
    Key? key,
    required this.imagePath,
    this.fallbackImagePath = 'assets/images/buddha.png', // Default fallback
    this.width = 65.0,
    this.height = 65.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(80.0),
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // If the image fails to load, use the fallback image
          return Image.asset(
            fallbackImagePath,
            width: width,
            height: height,
            fit: fit,
          );
        },
      ),
    );

    return imageWidget;
  }
}
