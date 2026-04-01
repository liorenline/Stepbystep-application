import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Фонові кола
            _buildBlob(top: 50, left: -30, color: Color(0xFFE8B4F8), size: 150),
            _buildBlob(top: 100, right: -20, color: Color(0xFFF0F8A0), size: 120),
            _buildBlob(bottom: 100, left: 20, color: Color(0xFFF0F8A0), size: 130),
            _buildBlob(bottom: 50, right: -10, color: Color(0xFFE8B4F8), size: 160),
            _buildBlob(top: 300, left: 50, color: Color(0xFFE8B4F8), size: 100),

            // Контент
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  children: [
                    SizedBox(height: 40),

                    // Логотип
                    Image.asset('assets/logo.png', height: 80),
                    SizedBox(height: 8),
                    Text(
                      'STEP BY STEP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D1A6E),
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Learn with Flashcards',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9B6BBE),
                      ),
                    ),

                    SizedBox(height: 32),

                    Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        suffixIcon: Icon(Icons.star, size: 12, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Вже є акаунт
                    GestureDetector(
                      onTap: () {
                        // Navigator.push до LoginScreen
                      },
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Password must contain 1 uppercase letter and 1 special character',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),

                    SizedBox(height: 16),

                    // Чекбокс
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (val) => setState(() => _acceptedTerms = val!),
                        ),
                        Expanded(
                          child: Text(
                            'I accept the terms of service and privacy policy',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Кнопка
                    OutlinedButton(
                      onPressed: _acceptedTerms ? () {
                        // логіка реєстрації
                      } : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(200, 48),
                        shape: StadiumBorder(),
                        side: BorderSide(color: Color(0xFF3D1A6E)),
                      ),
                      child: Text(
                        'Create an account',
                        style: TextStyle(color: Color(0xFF3D1A6E)),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob({double? top, double? bottom, double? left, double? right, required Color color, required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.5),
        ),
      ),
    );
  }
}