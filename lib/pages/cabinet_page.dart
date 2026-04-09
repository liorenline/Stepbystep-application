import 'dart:ui';
import 'package:flutter/material.dart';
import 'personal_information.dart';

class CabinetScreen extends StatelessWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _blurBlob(260, const Color(0xFFFFB3C6)),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _blurBlob(220, const Color(0xFFD4F5B0)),
          ),
          Positioned(
            top: 300,
            right: -40,
            child: _blurBlob(200, const Color(0xFFE1C4F5)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _blurBlob(240, const Color(0xFFFFB3C6)),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'STEP BY STEP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B2FBE),
                                    letterSpacing: 1.5,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  'Learn with Flashcards',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF00BCD4),
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),
                            Container(
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
                          ],
                        ),
                      ),

                      // BACK BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back to Home'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(color: Colors.black26),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),

                      // CENTER CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'My cabinet',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'serif',
                              ),
                            ),

                            const SizedBox(height: 48),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                children: [
                                  _menuButton(
                                    label: 'My progress',
                                    onTap: () {},
                                  ),
                                  const SizedBox(height: 16),
                                  _menuButton(
                                    label: 'Privacy Policy',
                                    onTap: () {},
                                  ),
                                  const SizedBox(height: 16),
                                  _menuButton(
                                    label: 'Personal Information',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const PersonalInformationPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _menuButton(
                                    label: 'Try Two-factor\nauthentication method',
                                    onTap: () {},
                                    multiline: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String label,
    required VoidCallback onTap,
    bool multiline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: multiline ? 14 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.black26,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontFamily: 'serif',
            height: 1.4,
          ),
        ),
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