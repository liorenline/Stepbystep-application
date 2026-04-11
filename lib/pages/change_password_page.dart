import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'verify_action_page.dart';

const _purple = Color(0xFF7B2FBE);
const _baseUrl = "https://stepbystep.fly.dev/api";

const _fieldBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black, width: 1.2),
);
const _fieldFocusedBorder = OutlineInputBorder(
  borderSide: BorderSide(color: _purple, width: 1.8),
);
const _baseDecoration = InputDecoration(
  border: _fieldBorder,
  enabledBorder: _fieldBorder,
  focusedBorder: _fieldFocusedBorder,
  filled: true,
  fillColor: Colors.white,
  labelStyle: TextStyle(color: Colors.black87),
  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
);

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _newVisible = false;
  bool _confirmVisible = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/user/${widget.userId}/send-change-password-code"),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() => _loading = false);

        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyActionPage(
              userId: widget.userId,
              title: "Confirm password change",
              description:
              "Enter the 6-digit code sent to your email to confirm the password change.",
              onVerified: (code) async {
                final r = await http.post(
                  Uri.parse(
                      "$_baseUrl/user/${widget.userId}/change-password"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "code": code,
                    "password": newPassword,
                  }),
                );
                final d = jsonDecode(r.body);
                return r.statusCode == 200 && d["success"] == true;
              },
            ),
          ),
        );

        if (changed == true && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password changed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _loading = false;
          _errorMessage = data["error"] ?? "Failed to send code.";
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = "Server error. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: -60,
              right: -60,
              child: _blob(260, const Color(0xFFFFB3C6))),
          Positioned(
              top: -60,
              left: -60,
              child: _blob(220, const Color(0xFFD4F5B0))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 24),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF0EAFD), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_reset,
                        color: _purple, size: 36),
                  ),
                  const Text("Create a new password",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your new password below. After confirming, "
                        "we'll send a verification code to your email.",
                    style: TextStyle(
                        fontSize: 14, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  const Text("New password",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_newVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: _baseDecoration.copyWith(
                      hintText: "Enter new password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _newVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: Colors.black54,
                        ),
                        onPressed: () =>
                            setState(() => _newVisible = !_newVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Confirm new password",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: _baseDecoration.copyWith(
                      hintText: "Repeat new password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: Colors.black54,
                        ),
                        onPressed: () => setState(
                                () => _confirmVisible = !_confirmVisible),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Text("Continue",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel",
                        style:
                        TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withOpacity(0.8)),
      ),
    );
  }
}