import 'package:flutter/material.dart';
import 'dart:ui';
import 'log_in.dart';
import 'main.page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Blobs — як на інших екранах
              Positioned(
                top: -80,
                left: -80,
                child: _blurBlob(280, const Color(0xFFFFB3C6)),
              ),
              Positioned(
                top: 60,
                right: -60,
                child: _blurBlob(200, const Color(0xFFE1C4F5)),
              ),
              Positioned(
                bottom: 80,
                left: 20,
                child: _blurBlob(220, const Color(0xFFD4F5B0)),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: _blurBlob(280, const Color(0xFFFFB3C6)),
              ),

              SafeArea(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Mascot placeholder
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: Color(0xFF7B2FBE),
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'STEP  BY  STEP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2FBE),
                            letterSpacing: 3,
                            fontFamily: 'serif',
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Learn with Flashcards',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00BCD4),
                            fontFamily: 'serif',
                          ),
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          'Welcome to our app!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'serif',
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Here, knowledge becomes simple\nand learning becomes interesting.\nStart your journey to success today!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.6,
                            fontFamily: 'serif',
                          ),
                        ),

                        const SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B2FBE),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blurBlob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }
}