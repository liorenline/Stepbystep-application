import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyEmailScreen extends StatefulWidget {
  final int userId;

  const VerifyEmailScreen({super.key, required this.userId});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;

  final String baseUrl = "https://stepbystep-cmnf.onrender.com/api/verify-email";

  Future<void> _verifyEmail() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showError("Enter verification code");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "code": code,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        _showSuccess(data["message"]);

        /// 🔥 після підтвердження — або логін, або home
        Navigator.pop(context);
        // або:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        _showError(data["error"]);
      }
    } catch (e) {
      _showError("Server is unavailable (try again)");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showSuccess(String msg) {
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter verification code",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Check your email and enter the code",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  letterSpacing: 5,
                ),
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
                      : const Text("Verify"),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  _showError("Resend not implemented yet");
                },
                child: const Text("Resend code"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}