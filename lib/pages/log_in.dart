import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up_screen.dart';
import 'main.page.dart';
import 'verify_2fa_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  void _clearErrors() {
    _emailError = null;
    _passwordError = null;
    _generalError = null;
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _clearErrors());

    bool hasError = false;
    if (email.isEmpty) {
      _emailError = 'Please enter your email';
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://stepbystep.fly.dev/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final responseData = data['data'];

        if (responseData['requires_2fa'] == true) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Verify2FAScreen(
                userId: responseData['user_id'],
                email: email,
              ),
            ),
          );
          return;
        }

        final username = responseData['username']?.toString() ?? 'User';
        final userId = responseData['user_id'];

        // Зберігаємо сесію локально на телефоні
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setInt('userId', userId);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: username, userId: userId),
          ),
        );
      } else {
        final errorMsg = data['error'] ?? 'Invalid credentials';
        setState(() {
          _emailError = '';
          _passwordError = '';
          _generalError = errorMsg;
        });
      }
    } catch (e) {
      setState(() => _generalError = 'Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool hasError,
    Widget? suffixIcon,
  }) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: hasError
          ? errorBorder
          : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: hasError
          ? errorBorder
          : OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF7B2FBE), width: 1.8),
      ),
    );
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
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'STEP  BY  STEP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2FBE),
                            letterSpacing: 3,
                            fontFamily: 'serif',
                          ),
                        ),
                        const Text(
                          'Learn with Flashcards',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00BCD4),
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {
                            _emailError = null;
                            _generalError = null;
                          }),
                          decoration: _fieldDecoration(
                            hint: 'example@mail.com',
                            hasError: _emailError != null && _emailError!.isNotEmpty,
                          ),
                        ),
                        if (_emailError != null && _emailError!.isNotEmpty)
                          _errorText(_emailError!),

                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {
                            _passwordError = null;
                            _generalError = null;
                          }),
                          decoration: _fieldDecoration(
                            hint: 'Password',
                            hasError: _passwordError != null && _passwordError!.isNotEmpty,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        if (_passwordError != null && _passwordError!.isNotEmpty)
                          _errorText(_passwordError!),

                        if (_generalError != null) ...[
                          const SizedBox(height: 10),
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
                                  child: Text(
                                    _generalError!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B2FBE),
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: _goToSignUp,
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Color(0xFF7B2FBE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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

  Widget _errorText(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 14),
          const SizedBox(width: 4),
          Text(msg, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
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