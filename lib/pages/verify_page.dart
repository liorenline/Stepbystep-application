import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'log_in.dart';

class VerifyEmailScreen extends StatefulWidget {
  final int userId;
  final String email;

  const VerifyEmailScreen({super.key, required this.userId, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;

  final String baseUrl = "https://stepbystep.fly.dev/api";
  Future<void> _verifyEmail() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showError("Enter verification code");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/verify-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "code": code,
        }),
      )
          .timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        _showMessage("Email verified! You can now log in.");
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        _showError(data["error"] ?? "Invalid or expired code.");
      }
    } catch (e) {
      _showError("Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/resend-verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      )
          .timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        _showMessage("A new code has been sent to ${widget.email}.");
      } else {
        _showError(data["error"] ?? "Failed to resend code.");
      }
    } catch (e) {
      _showError("Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isResending = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: const Color(0xFF7B2FBE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter verification code",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "A code was sent to ${widget.email}",
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 5),
                decoration: InputDecoration(
                  hintText: "------",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FBE),
                    shape: const StadiumBorder(),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              _isResending
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF7B2FBE),
                ),
              )
                  : TextButton(
                onPressed: _resendCode,
                child: const Text(
                  "Resend code",
                  style: TextStyle(color: Color(0xFF7B2FBE)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}