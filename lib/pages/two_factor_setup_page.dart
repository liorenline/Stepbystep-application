import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _purple = Color(0xFF7B2FBE);
const _baseUrl = "https://stepbystep.fly.dev/api";

const _fieldBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black, width: 1.2),
);
const _fieldFocusedBorder = OutlineInputBorder(
  borderSide: BorderSide(color: _purple, width: 1.8),
);
const _fieldDisabledBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black54, width: 1.0),
);
const _baseDecoration = InputDecoration(
  border: _fieldBorder,
  enabledBorder: _fieldBorder,
  focusedBorder: _fieldFocusedBorder,
  disabledBorder: _fieldDisabledBorder,
  filled: true,
  fillColor: Colors.white,
  labelStyle: TextStyle(color: Colors.black87),
  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
);

class TwoFactorSetupPage extends StatefulWidget {
  final int userId;

  const TwoFactorSetupPage({super.key, required this.userId});

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  final _codeController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/user/${widget.userId}/2fa/send-code"),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 && data["success"] == true) {
        setState(() => _codeSent = true);
      } else {
        setState(
                () => _errorMessage = data["error"] ?? "Failed to send code.");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = "Server error. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = "Please enter the 6-digit code.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/user/${widget.userId}/2fa/enable"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code}),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 && data["success"] == true) {
        Navigator.of(context).pop(true);
      } else {
        setState(() =>
        _errorMessage = data["error"] ?? "Invalid or expired code.");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = "Server error. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text("Set up 2FA",
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
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
                    child: const Icon(Icons.shield_outlined,
                        color: _purple, size: 36),
                  ),
                  const Text("Two-factor authentication",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    "Add an extra layer of security to your account. "
                        "When you sign in, you'll be asked for a one-time code "
                        "sent to your email address.",
                    style: TextStyle(
                        fontSize: 14, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  _buildStep(
                    number: "1",
                    title: "Send a verification code",
                    subtitle: "We'll email you a 6-digit code.",
                    child: _codeSent
                        ? Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        const Text("Code sent!",
                            style: TextStyle(
                                color: Colors.green, fontSize: 13)),
                        const Spacer(),
                        TextButton(
                          onPressed: _loading ? null : _sendCode,
                          style: TextButton.styleFrom(
                              foregroundColor: _purple),
                          child: const Text("Resend"),
                        ),
                      ],
                    )
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _sendCode,
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text("Send code to my email"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStep(
                    number: "2",
                    title: "Enter the code",
                    subtitle: "Type the 6-digit code from your email.",
                    child: Column(
                      children: [
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: _codeSent,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 28,
                              letterSpacing: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: _baseDecoration.copyWith(
                            hintText: "000000",
                            hintStyle: const TextStyle(
                                fontSize: 28,
                                letterSpacing: 12,
                                color: Colors.black26),
                            counterText: "",
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      (_codeSent && !_loading) ? _verifyCode : null,
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
                          : const Text(
                          "Enable two-factor authentication",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
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

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: _purple, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
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