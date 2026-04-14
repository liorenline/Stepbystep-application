import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.page.dart';

class Verify2FAScreen extends StatefulWidget {
  final int userId;
  final String email;

  const Verify2FAScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;

  final String baseUrl = "https://stepbystep.fly.dev/api";

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showError("Enter the verification code");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-2fa"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "code": code,
        }),
      ).timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final responseData = data["data"];
        final username = responseData["username"]?.toString() ?? "User";
        final userId = responseData["user_id"];

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: username, userId: userId),
          ),
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
      // Re-trigger login to resend the 2FA code — backend sends it on login
      // There's no standalone resend endpoint for 2FA login codes,
      // so we just inform the user to go back and log in again.
      // If you add a /resend-2fa endpoint later, call it here instead.
      _showMessage("Please go back and log in again to receive a new code.");
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
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
        title: const Text("Two-factor authentication"),
        backgroundColor: const Color(0xFF7B2FBE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 56,
                color: Color(0xFF7B2FBE),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enter verification code",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 5),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "------",
                  counterText: "",
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
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FBE),
                    shape: const StadiumBorder(),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Verify",
                    style: TextStyle(color: Colors.white),
                  ),
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
                  "Didn't receive a code?",
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