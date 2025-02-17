// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/isar_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutLogo;
  late Animation<double> _fadeInElements;
  late Animation<double> _fadeInTitle; // New animation for title
  int _loadingTextIndex = 0;
  final List<String> _loadingTexts = [
    'Loading resources...',
    'Initializing database...',
    'Preparing your experience...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _handleNavigation();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Reduced total duration
      vsync: this,
    );

    // Logo fades out faster
    _fadeOutLogo = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            const Interval(0.2, 0.3, curve: Curves.easeOut), // Earlier fade out
      ),
    );

    // Separate animation for title
    _fadeInTitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    // Delay loading elements animation
    _fadeInElements = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _cycleLoadingText();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {});
      }
    });
  }

  Future<void> _handleNavigation() async {
    // Wait for minimum splash display time
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      final isFirstLaunch = await isarService.isFirstLaunch();

      if (!mounted) return;

      // Navigate based on first launch status
      Navigator.pushReplacementNamed(
        context,
        isFirstLaunch ? '/language' : '/home',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking app status: $e')),
      );
      // Default to language selection on error
      Navigator.pushReplacementNamed(context, '/language');
    }
  }

  void _cycleLoadingText() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _loadingTextIndex = (_loadingTextIndex + 1) % _loadingTexts.length;
        });
        _cycleLoadingText();
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Logo animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeOutLogo.value,
                  child: ClipOval(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      child: Image.asset(
                        'assets/images/buddha.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content layout
          Column(
            children: [
              // Title with its own fade animation
              Expanded(
                flex: 2,
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeInTitle,
                    child: Text(
                      'The Sanatan',
                      style: GoogleFonts.niconne(
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading elements at bottom
              FadeTransition(
                opacity: _fadeInElements,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.shade800),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.5),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _loadingTexts[_loadingTextIndex],
                          key: ValueKey<int>(_loadingTextIndex),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
