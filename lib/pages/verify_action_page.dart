import 'dart:ui';
import 'package:flutter/material.dart';
import 'personal_information.dart';

// ─────────────────────────────────────────────
//  Shared constants (copy from personal_information_page.dart
//  or move to a shared constants file)
// ─────────────────────────────────────────────
const _purple = Color(0xFF7B2FBE);

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

// ─────────────────────────────────────────────
//  VerifyActionPage
//
//  A reusable verification page for any action that requires
//  a 6-digit email code (password change, disable 2FA, etc.)
//
//  Usage:
//    final success = await Navigator.push<bool>(
//      context,
//      MaterialPageRoute(
//        builder: (_) => VerifyActionPage(
//          userId: widget.userId,
//          title: "Confirm password change",
//          description: "Enter the 6-digit code sent to your email.",
//          onVerified: (code) async {
//            // perform the action and return true on success
//            return true;
//          },
//        ),
//      ),
//    );
// ─────────────────────────────────────────────
class VerifyActionPage extends StatefulWidget {
  final int userId;
  final String title;
  final String description;

  /// Called with the entered code. Should return `true` if the action succeeded.
  final Future<bool> Function(String code) onVerified;

  const VerifyActionPage({
    super.key,
    required this.userId,
    required this.title,
    required this.description,
    required this.onVerified,
  });

  @override
  State<VerifyActionPage> createState() => _VerifyActionPageState();
}

class _VerifyActionPageState extends State<VerifyActionPage> {
  final _codeController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
      final success = await widget.onVerified(code);
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = "Invalid or expired code. Try again.");
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
        title: Text(
          widget.title,
          style: const TextStyle(
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

                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 24),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0EAFD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: _purple, size: 36),
                  ),

                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 36),

                  // Code input
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: _baseDecoration.copyWith(
                      hintText: "000000",
                      hintStyle: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 12,
                        color: Colors.black26,
                      ),
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
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Confirm",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
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