import 'package:flutter/material.dart';
import 'package:dharmic/components/circle_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:dharmic/services/isar_service.dart';
import 'package:dharmic/models/quote.dart';
import 'dart:ui' show lerpDouble;

class FloatingButtons extends StatefulWidget {
  final Quote quote;

  const FloatingButtons({
    super.key,
    required this.quote,
  });

  @override
  State<FloatingButtons> createState() => _FloatingButtonsState();
}

class _FloatingButtonsState extends State<FloatingButtons>
    with TickerProviderStateMixin {
  bool _isExpanded = false;

  late final AnimationController _rotationController;
  late final List<AnimationController> _buttonControllers;
  static const _buttonDelay = Duration(milliseconds: 200);
  static const _reverseDelay = Duration(milliseconds: 50);

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _rotationController.dispose();
    for (var controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final pageHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        height: pageHeight,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideOverlay,
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 72,
                child: SizedBox(
                  height: 400,
                  width: 250,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAnimatedButtonWithLabel(
                        controller: _buttonControllers[3],
                        label: 'Share',
                        icon: Icons.share,
                        offset: 280,
                        onPressed: () {
                          Share.share(
                              '${widget.quote.quote}\n- ${widget.quote.author}');
                          _hideOverlay();
                        },
                        index: 3,
                      ),
                      _buildAnimatedButtonWithLabel(
                        controller: _buttonControllers[2],
                        label: 'Language',
                        icon: Icons.language,
                        offset: 210,
                        onPressed: () {},
                        index: 2,
                      ),
                      Consumer<IsarService>(
                        builder: (context, isarService, _) {
                          return _buildAnimatedButtonWithLabel(
                            controller: _buttonControllers[1],
                            label: 'Speak',
                            icon: isarService.speakIcon,
                            offset: 140,
                            onPressed: () =>
                                isarService.handleSpeech(widget.quote.quote),
                            index: 1,
                            isActive: isarService.isSpeaking &&
                                isarService.currentQuote == widget.quote.quote,
                          );
                        },
                      ),
                      Consumer<IsarService>(
                        builder: (context, isarService, _) {
                          return _buildAnimatedButtonWithLabel(
                            controller: _buttonControllers[0],
                            label: 'Bookmark',
                            icon: widget.quote.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            offset: 70,
                            onPressed: () =>
                                isarService.toggleBookmark(widget.quote),
                            index: 0,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _toggleMenu();
  }

  void _toggleMenu() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _rotationController.forward();
      _showOverlay(context);
      for (var i = 0; i < _buttonControllers.length; i++) {
        Future.delayed(_buttonDelay * i, () {
          if (mounted) _buttonControllers[i].forward();
        });
      }
    } else {
      _rotationController.reverse();
      for (var i = _buttonControllers.length - 1; i >= 0; i--) {
        Future.delayed(_reverseDelay * (_buttonControllers.length - 1 - i), () {
          if (mounted) _buttonControllers[i].reverse(from: 1.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0 / 4).animate(
        CurvedAnimation(
          parent: _rotationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: CircleButton(
        icon: Icons.edit,
        onPressed: _toggleMenu,
      ),
    );
  }

  Widget _buildAnimatedButtonWithLabel({
    required AnimationController controller,
    required String label,
    required IconData icon,
    required double offset,
    required VoidCallback onPressed,
    required int index,
    bool isActive = false,
  }) {
    return Positioned(
      bottom: offset,
      right: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: const Offset(-0.2, 0),
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                reverseCurve: Curves.easeInBack,
              ),
            ),
            child: FadeTransition(
              opacity: controller,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          ScaleTransition(
            alignment: Alignment.center,
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInBack,
              ),
            ),
            child: Transform.scale(
              scale: 0.8,
              child: CircleButton(
                icon: icon,
                onPressed: onPressed,
                isActive: isActive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
