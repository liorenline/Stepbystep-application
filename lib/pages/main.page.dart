import 'package:flutter/material.dart';
import 'dart:ui';
import 'personal_information.dart';
import 'cabinet_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.username = 'username'});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: _blurBlob(260, const Color(0xFFD4F5B0)),
              ),
              Positioned(
                top: 100,
                right: -60,
                child: _blurBlob(220, const Color(0xFFFFB3C6)),
              ),
              Positioned(
                bottom: 100,
                left: -40,
                child: _blurBlob(200, const Color(0xFFFFB3C6)),
              ),
              Positioned(
                bottom: -60,
                right: -60,
                child: _blurBlob(240, const Color(0xFFE1C4F5)),
              ),

              SafeArea(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      // TOP BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'STEP BY STEP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B2FBE),
                                    letterSpacing: 1.5,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                const Text(
                                  'Learn with Flashcards',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF00BCD4),
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),

                            // Avatar
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const CabinetScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF7B2FBE),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF7B2FBE),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Hello, $username!',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'serif',
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "You don't have any decks yet.\nLet's create your first deck!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.6,
                                fontFamily: 'serif',
                              ),
                            ),

                            const SizedBox(height: 48),

                            // + button
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black54,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 28,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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