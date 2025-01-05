import 'package:flutter/material.dart';

class CustomPageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double activeDotSize;
  final double spacing;

  const CustomPageIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor = const Color(0xFFfa5620),
    this.inactiveColor = Colors.white,
    this.dotSize = 8.0,
    this.activeDotSize = 10.0,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return _buildSingleDot();
    }

    if (totalPages < 5) {
      return _buildSmallPagination();
    }

    return _buildLargePagination();
  }

  Widget _buildSingleDot() {
    return Center(
      child: Container(
        width: activeDotSize,
        height: activeDotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor,
        ),
      ),
    );
  }

  Widget _buildSmallPagination() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalPages, (index) {
          final isActive = index == currentPage;
          final isEdge =
              totalPages >= 3 && (index == 0 || index == totalPages - 1);

          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isActive ? 1.2 : 1.0,
            child: Container(
              width: isActive ? activeDotSize : dotSize,
              height: isActive ? activeDotSize : dotSize,
              margin: EdgeInsets.symmetric(horizontal: spacing),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLargePagination() {
    return Center(
      child: SizedBox(
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final isFirstDot = index == 0;
            final isLastDot = index == 4;

            int activeDotPosition;
            if (currentPage <= 2) {
              activeDotPosition = currentPage;
            } else if (currentPage >= totalPages - 2) {
              activeDotPosition = 4 - (totalPages - currentPage - 1);
            } else {
              activeDotPosition = 2;
            }

            final bool isActive = index == activeDotPosition;
            final bool isSmall = (isFirstDot && currentPage > 2) ||
                (isLastDot && currentPage < totalPages - 3);

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  offset: Offset(currentPage > 2 ? -0.2 : 0, 0),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isActive ? 1.2 : (isSmall ? 0.6 : 1.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isActive ? spacing + 2 : spacing,
                      ),
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
