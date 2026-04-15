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
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  final String baseUrl = "https://stepbystep.fly.dev/api";

  // Password requirement checks
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'));

  bool get _passwordFocused => _showPasswordHints;
  bool _showPasswordHints = false;

  bool get _isPasswordValid =>
      _hasMinLength && _hasUppercase && _hasDigit && _hasSpecial;

  void _clearErrors() {
    _usernameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmError = null;
    _generalError = null;
  }

  bool _validateFields() {
    bool ok = true;
    _clearErrors();

    if (_usernameController.text.trim().isEmpty) {
      _usernameError = 'Username is required';
      ok = false;
    }
    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Email is required';
      ok = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(_emailController.text.trim())) {
      _emailError = 'Enter a valid email';
      ok = false;
    }
    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password is required';
      ok = false;
    } else if (!_isPasswordValid) {
      _passwordError = 'Password does not meet requirements';
      ok = false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _confirmError = 'Please confirm your password';
      ok = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmError = 'Passwords do not match';
      ok = false;
    }
    return ok;
  }

  Future<void> _signUp() async {
    if (!_validateFields()) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "confirm_password": confirm,
        }),
      ).timeout(const Duration(seconds: 90));

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 409) {
        await _resendAndNavigate(email);
        return;
      }

      if (response.statusCode != 200) {
        setState(() => _generalError = data["error"] ?? "Server error");
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (data["success"] == true) {
        final userId = data["data"]?["user_id"];
        if (userId == null) {
          setState(() => _generalError = "Invalid server response");
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(userId: userId, email: email),
          ),
        );
      } else {
        setState(() => _generalError = data["error"] ?? "Registration failed");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _generalError = "Server is unavailable. Please try again.");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendAndNavigate(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/resend-verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final userId = data["data"]?["user_id"];
        if (userId == null) {
          setState(() => _generalError = "Invalid server response");
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        if (!mounted) return;
        setState(() => _isLoading = false);
        setState(() => _emailError =
        "Already registered but not verified. New code sent.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(userId: userId, email: email),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _generalError = data["error"] ?? "Failed to resend verification code.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generalError = "Server is unavailable. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _fieldDecoration({
    required bool hasError,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      border: _border(Colors.black),
      enabledBorder:
      hasError ? _border(Colors.red, width: 1.5) : _border(Colors.black),
      focusedBorder: hasError
          ? _border(Colors.red, width: 1.5)
          : _border(const Color(0xFF7B2FBE), width: 1.8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
              top: -80,
              left: -80,
              child: _blurBlob(300, const Color(0xFFFFB3C6))),
          Positioned(
              bottom: -80,
              right: -80,
              child: _blurBlob(300, const Color(0xFFD4F5B0))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'STEP  BY  STEP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2FBE),
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username
                  _label("Username"),
                  TextField(
                    controller: _usernameController,
                    onChanged: (_) =>
                        setState(() => _usernameError = null),
                    decoration:
                    _fieldDecoration(hasError: _usernameError != null),
                  ),
                  if (_usernameError != null) _errorText(_usernameError!),
                  const SizedBox(height: 16),

                  // Email
                  _label("Email"),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() => _emailError = null),
                    decoration:
                    _fieldDecoration(hasError: _emailError != null),
                  ),
                  if (_emailError != null) _errorText(_emailError!),
                  const SizedBox(height: 16),

                  // Password
                  _label("Password"),
                  Focus(
                    onFocusChange: (focused) =>
                        setState(() => _showPasswordHints = focused ||
                            _passwordController.text.isNotEmpty),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) =>
                          setState(() => _passwordError = null),
                      decoration: _fieldDecoration(
                        hasError: _passwordError != null,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  if (_passwordError != null) _errorText(_passwordError!),

                  // Password requirements checklist
                  if (_showPasswordHints || _passwordError != null) ...[
                    const SizedBox(height: 8),
                    _passwordRequirement(
                        'At least 8 characters', _hasMinLength),
                    _passwordRequirement(
                        'At least one uppercase letter (A-Z)', _hasUppercase),
                    _passwordRequirement(
                        'At least one digit (0-9)', _hasDigit),
                    _passwordRequirement(
                        'At least one special character (!@#\$...)',
                        _hasSpecial),
                  ],
                  const SizedBox(height: 16),

                  // Confirm password
                  _label("Confirm Password"),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    onChanged: (_) =>
                        setState(() => _confirmError = null),
                    decoration: _fieldDecoration(
                      hasError: _confirmError != null,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  if (_confirmError != null) _errorText(_confirmError!),

                  if (_generalError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_generalError!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
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
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'Create an account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _errorText(String msg) => Padding(
    padding: const EdgeInsets.only(top: 5, left: 2),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(msg,
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    ),
  );

  Widget _passwordRequirement(String text, bool met) => Padding(
    padding: const EdgeInsets.only(top: 3, left: 2),
    child: Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: met ? Colors.green : Colors.black45,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.green : Colors.black45,
          ),
        ),
      ],
    ),
  );

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