import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/isar_service.dart';
import 'package:rive/rive.dart' as rive;

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'en'; // Default to English
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _quoteAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _quoteAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212),
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Animated Title
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Choose Your Language',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Language Selection Tabs
                        _buildLanguageSelectionTabs(),

                        const SizedBox(height: 30),

                        // Animation container - original size
                        const SizedBox(
                          height: 200,
                          child: rive.RiveAnimation.asset(
                            'assets/cat_following_the_mouse.riv',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Quote Card
                        AnimatedBuilder(
                          animation: _quoteAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _quoteAnimation.value,
                              child: Transform.translate(
                                offset:
                                    Offset(0, 20 * (1 - _quoteAnimation.value)),
                                child: _buildQuoteCard(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Next Button - fixed to bottom
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionTabs() {
    return Container(
      height: 56,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLanguageTab('English', 'en'),
          _buildLanguageTab('Hinglish', 'hi'),
        ],
      ),
    );
  }

  Widget _buildLanguageTab(String language, String langCode) {
    final isSelected = selectedLanguage == langCode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selectedLanguage != langCode) {
            setState(() {
              selectedLanguage = langCode;
            });
            _controller.reset();
            _controller.forward();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              language,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    final quote = selectedLanguage == 'en'
        ? 'Knowledge is the eternal wealth that none can steal.'
        : 'Karm karo, phal ki chinta mat karo.';
    final author = 'Lord Krishna';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF292929),
            Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.format_quote,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            quote,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "~ $author",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E56F7),
            Color(0xFF563EE3),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6E56F7).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFfa5620),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Future<void> _onNextPressed() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final isarService = Provider.of<IsarService>(context, listen: false);
      await isarService.setFirstLaunchComplete(selectedLanguage);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save language selection: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      setState(() => _isSaving = false);
    }
  }
}
