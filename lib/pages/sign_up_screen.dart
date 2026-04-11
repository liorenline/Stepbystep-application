import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verify_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final String baseUrl = "https://stepbystep.fly.dev/api";

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError("All fields are required");
      return;
    }

    if (password != confirm) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    _showMessage("Connecting to server, please wait...");

    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "confirm_password": confirm,
        }),
      )
          .timeout(const Duration(seconds: 90));

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Email exists but not verified — resend code and go to verify screen
      if (response.statusCode == 409) {
        await _resendAndNavigate(email);
        return;
      }

      if (response.statusCode != 200) {
        _showError(data["error"] ?? "Server error");
        return;
      }

      if (data["success"] == true) {
        final userId = data["data"]?["user_id"];
        if (userId == null) {
          _showError("Invalid server response");
          return;
        }

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(userId: userId, email: email),
          ),
        );
      } else {
        _showError(data["error"] ?? "Registration failed");
      }
    } catch (e) {
      _showError("Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resendAndNavigate(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/resend-verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      )
          .timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final userId = data["data"]?["user_id"];
        if (userId == null) {
          _showError("Invalid server response");
          return;
        }

        if (!mounted) return;
        _showError("This email is already registered but not verified. A new code has been sent.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(userId: userId, email: email),
          ),
        );
      } else {
        _showError(data["error"] ?? "Failed to resend verification code.");
      }
    } catch (e) {
      _showError("Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                top: -80,
                left: -80,
                child: _blurBlob(300, const Color(0xFFFFB3C6)),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: _blurBlob(300, const Color(0xFFD4F5B0)),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'STEP  BY  STEP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2FBE),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _input("Username", _usernameController),
                        _input("Email", _emailController),
                        _input("Password", _passwordController, isPassword: true),
                        _input("Confirm Password", _confirmPasswordController, isPassword: true),
                        const SizedBox(height: 10),
                        const Text(
                          'Password must contain 1 uppercase letter and 1 special character',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B2FBE),
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text(
                              'Create an account',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _input(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
          ),
        ),
        const SizedBox(height: 16),
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