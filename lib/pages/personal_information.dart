import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonalInformationPage extends StatefulWidget {
  final int userId;

  const PersonalInformationPage({
    super.key,
    required this.userId,
  });

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _firstNameEnabled = false;
  bool _lastNameEnabled = false;
  bool _emailEnabled = false;
  bool _passwordEnabled = false;

  final String baseUrl = "https://stepbystep-cmnf.onrender.com/api";

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/${widget.userId}"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _firstNameController.text = data["username"] ?? "";
          _emailController.text = data["email"] ?? "";
        });
      }
    } catch (e) {
      print("Load user error: $e");
    }
  }

  void _saveProfile() {
    // Тут підключиш PUT API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved (API not connected yet)')),
    );
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            top: -60,
            left: -60,
            child: _blurBlob(220, const Color(0xFFD4F5B0)),
          ),

          SafeArea(
            child: Column(
              children: [
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
                            ),
                          ),
                          Text(
                            'Learn with Flashcards',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      const Icon(Icons.person_outline),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        const Center(
                          child: Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        _buildField(
                          label: 'First Name',
                          controller: _firstNameController,
                          enabled: _firstNameEnabled,
                          onEdit: () {
                            setState(() {
                              _firstNameEnabled = !_firstNameEnabled;
                              if (!_firstNameEnabled) _saveProfile();
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          enabled: _lastNameEnabled,
                          onEdit: () {
                            setState(() {
                              _lastNameEnabled = !_lastNameEnabled;
                              if (!_lastNameEnabled) _saveProfile();
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Email',
                          controller: _emailController,
                          enabled: _emailEnabled,
                          keyboardType: TextInputType.emailAddress,
                          onEdit: () {
                            setState(() {
                              _emailEnabled = !_emailEnabled;
                              if (!_emailEnabled) _saveProfile();
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildField(
                          label: 'Password',
                          controller: _passwordController,
                          enabled: _passwordEnabled,
                          obscureText: true,
                          onEdit: () {
                            setState(() {
                              _passwordEnabled = !_passwordEnabled;
                              if (!_passwordEnabled) _saveProfile();
                            });
                          },
                        ),

                        const SizedBox(height: 36),
                        const Divider(),
                        const SizedBox(height: 32),

                        Center(
                          child: OutlinedButton(
                            onPressed: _showDeleteDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
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
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                obscureText: obscureText && !enabled,
                keyboardType: keyboardType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onEdit,
              child: Text(enabled ? 'Save' : 'Edit'),
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