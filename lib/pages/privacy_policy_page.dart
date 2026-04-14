import 'dart:ui';
import 'package:flutter/material.dart';
import 'technical_support_page.dart'; // ← підключи правильний шлях до свого файлу

const _purple = Color(0xFF7B2FBE);
const _cyan = Color(0xFF00BCD4);

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _blob(260, const Color(0xFFFFB3C6)),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: _blob(220, const Color(0xFFD4F5B0)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _blob(200, const Color(0xFFE1C4F5)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: _purple, size: 20),
                      ),
                      const Column(
                        children: [
                          Text(
                            'STEP BY STEP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _purple,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Learn with Flashcards',
                            style: TextStyle(fontSize: 10, color: _cyan),
                          ),
                        ],
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: April 2025',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _section(
                          icon: Icons.info_outline_rounded,
                          title: '1. Information We Collect',
                          body:
                          'We collect information you provide directly to us when you create an account, '
                              'such as your username, email address, and password. '
                              'We also collect data about your study progress within the app.',
                        ),
                        _section(
                          icon: Icons.storage_rounded,
                          title: '2. How We Use Your Information',
                          body:
                          'We use the information we collect to provide, maintain, and improve our services, '
                              'to personalize your learning experience, send you technical notices, '
                              'and respond to your comments and questions.',
                        ),
                        _section(
                          icon: Icons.share_outlined,
                          title: '3. Information Sharing',
                          body:
                          'We do not sell, trade, or otherwise transfer your personal information to third parties. '
                              'Your data is used solely to provide you with the Step By Step learning service.',
                        ),
                        _section(
                          icon: Icons.lock_outline_rounded,
                          title: '4. Data Security',
                          body:
                          'We implement appropriate security measures to protect your personal information. '
                              'Your password is stored in encrypted form. '
                              'We use HTTPS for all data transmission.',
                        ),
                        _section(
                          icon: Icons.verified_user_outlined,
                          title: '5. Two-Factor Authentication',
                          body:
                          'We offer optional two-factor authentication (2FA) to enhance the security of your account. '
                              'When enabled, a verification code is sent to your email for sensitive actions.',
                        ),
                        _section(
                          icon: Icons.delete_outline_rounded,
                          title: '6. Data Deletion',
                          body:
                          'You can delete your account at any time from the Personal Information section. '
                              'Upon deletion, all your personal data including username, email, decks, '
                              'cards, and study progress will be permanently removed from our servers.',
                        ),
                        _section(
                          icon: Icons.update_rounded,
                          title: '7. Changes to This Policy',
                          body:
                          'We may update this Privacy Policy from time to time. '
                              'We will notify you of any changes by posting the new policy in the app. '
                              'Your continued use of the app after changes constitutes acceptance.',
                        ),

                        // ── 8. Contact Us — тапабельний, веде на TechnicalSupportPage ──
                        _sectionTappable(
                          context: context,
                          icon: Icons.email_outlined,
                          title: '8. Contact Us',
                          body:
                          'If you have any questions about this Privacy Policy, '
                              'please contact us at: step.by.step.ver.code@gmail.com',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TechnicalSupportPage(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _purple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTappable({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: _purple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.black38),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
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