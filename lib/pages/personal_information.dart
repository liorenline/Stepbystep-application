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
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _usernameEnabled = false;
  bool _emailEnabled = false;
  bool _passwordEnabled = false;

  final String baseUrl = "https://stepbystep.fly.dev/api";

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
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
      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          _usernameController.text = data["data"]["username"] ?? "";
          _emailController.text = data["data"]["email"] ?? "";
        });
      }
    } catch (e) {
      print("Load user error: $e");
    }
  }

  Future<void> _saveProfile() async {
    try {
      final body = <String, String>{};
      if (_usernameController.text.isNotEmpty) body["username"] = _usernameController.text.trim();
      if (_emailController.text.isNotEmpty) body["email"] = _emailController.text.trim();
      if (_passwordController.text.isNotEmpty) body["password"] = _passwordController.text;

      final response = await http.put(
        Uri.parse("$baseUrl/user/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Error"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error"), backgroundColor: Colors.red),
      );
    }
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
    _usernameController.dispose();
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
          Positioned(top: -60, right: -60, child: _blurBlob(260, const Color(0xFFFFB3C6))),
          Positioned(top: -60, left: -60, child: _blurBlob(220, const Color(0xFFD4F5B0))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('STEP BY STEP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7B2FBE))),
                          Text('Learn with Flashcards', style: TextStyle(fontSize: 10)),
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
                        const Center(child: Text('Personal Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 36),
                        _buildField(
                          label: 'Username',
                          controller: _usernameController,
                          enabled: _usernameEnabled,
                          onEdit: () async {
                            if (_usernameEnabled) await _saveProfile();
                            setState(() => _usernameEnabled = !_usernameEnabled);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Email',
                          controller: _emailController,
                          enabled: _emailEnabled,
                          keyboardType: TextInputType.emailAddress,
                          onEdit: () async {
                            if (_emailEnabled) await _saveProfile();
                            setState(() => _emailEnabled = !_emailEnabled);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Password',
                          controller: _passwordController,
                          enabled: _passwordEnabled,
                          obscureText: true,
                          onEdit: () async {
                            if (_passwordEnabled) await _saveProfile();
                            setState(() => _passwordEnabled = !_passwordEnabled);
                          },
                        ),
                        const SizedBox(height: 36),
                        const Divider(),
                        const SizedBox(height: 32),
                        Center(
                          child: OutlinedButton(
                            onPressed: _showDeleteDialog,
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.8)),
      ),
    );
  }
}