import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _purple = Color(0xFF7B2FBE);
const _cyan = Color(0xFF00BCD4);

class TechnicalSupportPage extends StatelessWidget {
  const TechnicalSupportPage({super.key});

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'step.by.step.ver.code@gmail.com',
      queryParameters: {
        'subject': 'Technical Support Request',
        'body': 'Hello, I need help with...',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            right: -60,
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
                          'Technical Support',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              size: 56,
                              color: _purple,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          'Having trouble? We\'re here to help!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'If you\'re experiencing any issues with the app, '
                              'have questions, or want to share feedback — '
                              'don\'t hesitate to reach out to us. '
                              'We usually respond within 24 hours.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 40),

                        _infoCard(
                          icon: Icons.email_outlined,
                          title: 'Email us',
                          subtitle: 'step.by.step.ver.code@gmail.com',
                          onTap: _launchEmail,
                          showArrow: false,
                        ),

                        const SizedBox(height: 16),

                        _infoCard(
                          icon: Icons.help_outline_rounded,
                          title: 'Common issues',
                          subtitle:
                          'Can\'t log in • App crashes • Sync problems • Lost progress',
                          onTap: null,
                        ),

                        const SizedBox(height: 16),

                        _infoCard(
                          icon: Icons.access_time_rounded,
                          title: 'Response time',
                          subtitle:
                          'We typically respond within 24 hours on business days.',
                          onTap: null,
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _launchEmail,
                            icon: const Icon(Icons.mail_outline,
                                color: Colors.white),
                            label: const Text(
                              'Send an email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _purple,
                              shape: const StadiumBorder(),
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _purple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null && showArrow)
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.black38),
          ],
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