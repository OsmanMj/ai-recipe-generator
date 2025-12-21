import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List<String> _loadingTexts = [
    "We're looking for the best recipes for you...",
    "Heating up the pans...",
    "Chopping fresh ingredients...",
    "Seasoning with love...",
    "Almost ready to serve!",
  ];

  final List<String> _backgroundImages = [
    "assets/images/loading1.png",
    "assets/images/loading2.png", // loading2.png was missing, using loading.png
    "assets/images/loading3.png",
  ];

  int _currentIndex = 0;
  int _currentImageIndex = 0;
  Timer? _textTimer;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    _startTextRotation();
    _startImageRotation();
  }

  void _startTextRotation() {
    _textTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _loadingTexts.length;
        });
      }
    });
  }

  void _startImageRotation() {
    _imageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Full Background Image with Transition
          Positioned.fill(
            child: AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: 1000), // Smooth transition speed
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _backgroundImages[_currentImageIndex],
                key: ValueKey<String>(_backgroundImages[_currentImageIndex]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Optional: Dark overlay for better text contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(), // Push content towards center/bottom

                  // Animated Text Switcher
                  SizedBox(
                    height: 80,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
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
                        _loadingTexts[_currentIndex],
                        key: ValueKey<String>(_loadingTexts[_currentIndex]),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white70, // Ensure white text on background
                          shadows: [
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // White loader
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 60), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
