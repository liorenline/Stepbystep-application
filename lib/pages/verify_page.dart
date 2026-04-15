import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'log_in.dart';

class VerifyEmailScreen extends StatefulWidget {
  final int userId;
  final String email;

  const VerifyEmailScreen(
      {super.key, required this.userId, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _codeError;
  String? _successMessage;

  final String baseUrl = "https://stepbystep.fly.dev/api";

  Future<void> _verifyEmail() async {
    final code = _codeController.text.trim();
    setState(() {
      _codeError = null;
      _successMessage = null;
    });

    if (code.isEmpty) {
      setState(() => _codeError = "Enter the verification code");
      return;
    }
    if (code.length != 6) {
      setState(() => _codeError = "Code must be 6 digits");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": widget.userId, "code": code}),
      ).timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        setState(() =>
        _codeError = data["error"] ?? "Invalid or expired code.");
      }
    } catch (e) {
      setState(
              () => _codeError = "Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _codeError = null;
      _successMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/resend-verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      ).timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() =>
        _successMessage = "A new code has been sent to ${widget.email}.");
      } else {
        setState(
                () => _codeError = data["error"] ?? "Failed to resend code.");
      }
    } catch (e) {
      setState(
              () => _codeError = "Server is unavailable. Please try again.");
    }

    if (mounted) setState(() => _isResending = false);
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
                style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                style:
                const TextStyle(fontSize: 20, letterSpacing: 5),
                maxLength: 6,
                onChanged: (_) =>
                    setState(() => _codeError = null),
                decoration: InputDecoration(
                  hintText: "------",
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _codeError != null
                          ? Colors.red
                          : Colors.black,
                      width: _codeError != null ? 1.5 : 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _codeError != null
                          ? Colors.red
                          : const Color(0xFF7B2FBE),
                      width: 1.8,
                    ),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (_codeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(_codeError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(_successMessage!,
                            style: const TextStyle(
                                color: Colors.green, fontSize: 12)),
                      ),
                    ],
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
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text("Verify",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              _isResending
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7B2FBE)),
              )
                  : TextButton(
                onPressed: _resendCode,
                child: const Text("Resend code",
                    style:
                    TextStyle(color: Color(0xFF7B2FBE))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}