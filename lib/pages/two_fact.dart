import 'package:flutter/material.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;

  Future<void> verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (_codeController.text == "123456") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("2FA verified")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> resendCode() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Code resent")),
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
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: _blob(300, const Color(0xFFFFB3C6)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _blob(300, const Color(0xFFD4F5B0)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

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
                    'Secure your account',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF00BCD4),
                      fontFamily: 'serif',
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    '2FA Verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'serif',
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Enter the 6-digit code sent to your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "------",
                      hintStyle: const TextStyle(
                        letterSpacing: 10,
                        color: Colors.black26,
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF7B2FBE),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: resendCode,
                    child: const Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(
                        color: Color(0xFF7B2FBE),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2FBE),
                        shape: const StadiumBorder(),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
      ),
    );
  }
}