import 'dart:ui';
import 'package:flutter/material.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _firstNameController = TextEditingController(text: 'John');
  final _lastNameController = TextEditingController(text: 'Doe');
  final _emailController = TextEditingController(text: 'johndoe@mail.com');
  final _passwordController = TextEditingController(text: '12345678');

  bool _firstNameEnabled = false;
  bool _lastNameEnabled = false;
  bool _emailEnabled = false;
  bool _passwordEnabled = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blob — top right (pink)
          Positioned(
            top: -60,
            right: -60,
            child: _blurBlob(260, const Color(0xFFFFB3C6)),
          ),
          // Blob — top left (green)
          Positioned(
            top: -60,
            left: -60,
            child: _blurBlob(220, const Color(0xFFD4F5B0)),
          ),
          // Blob — center right (purple)
          Positioned(
            top: 300,
            right: -40,
            child: _blurBlob(200, const Color(0xFFE1C4F5)),
          ),
          // Blob — bottom left (pink)
          Positioned(
            bottom: -60,
            left: -60,
            child: _blurBlob(240, const Color(0xFFFFB3C6)),
          ),
          // Blob — bottom right (green)
          Positioned(
            bottom: -60,
            right: -60,
            child: _blurBlob(220, const Color(0xFFD4F5B0)),
          ),

          // Content
          SafeArea(
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

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Cabinet'),
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

                        const SizedBox(height: 28),

                        const Center(
                          child: Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        _buildField(
                          label: 'First Name',
                          controller: _firstNameController,
                          enabled: _firstNameEnabled,
                          editLabel: 'Edit',
                          onEdit: () => setState(
                                  () => _firstNameEnabled = !_firstNameEnabled),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          enabled: _lastNameEnabled,
                          editLabel: 'Edit',
                          onEdit: () => setState(
                                  () => _lastNameEnabled = !_lastNameEnabled),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Email',
                          controller: _emailController,
                          enabled: _emailEnabled,
                          editLabel: 'Edit email',
                          onEdit: () =>
                              setState(() => _emailEnabled = !_emailEnabled),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Password',
                          controller: _passwordController,
                          enabled: _passwordEnabled,
                          editLabel: 'Edit password',
                          onEdit: () =>
                              setState(() => _passwordEnabled = !_passwordEnabled),
                          obscureText: true,
                        ),

                        const SizedBox(height: 36),
                        const Divider(color: Colors.black12),
                        const SizedBox(height: 32),

                        Center(
                          child: OutlinedButton(
                            onPressed: _showDeleteDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                  color: Colors.red, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 14),
                              textStyle: const TextStyle(fontSize: 15),
                            ),
                            child: const Text('Delete account'),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required String editLabel,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscureText && !enabled,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                    enabled ? Colors.white : const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                      const BorderSide(color: Color(0xFF7C5CFC)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C5CFC),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: Text(
                  enabled ? 'Save' : editLabel,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ],
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