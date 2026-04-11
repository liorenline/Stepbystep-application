import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'verify_action_page.dart';
import 'two_factor_setup_page.dart';
import 'change_password_page.dart';

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

class PersonalInformationPage extends StatefulWidget {
  final int userId;

  const PersonalInformationPage({super.key, required this.userId});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  bool _usernameEnabled = false;
  bool _emailEnabled = false;
  bool _twoFactorEnabled = false;
  bool _twoFactorLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final res = await http.get(Uri.parse("$_baseUrl/user/${widget.userId}"));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          _usernameController.text = data["data"]["username"] ?? "";
          _emailController.text = data["data"]["email"] ?? "";
          _twoFactorEnabled = data["data"]["two_factor_enabled"] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Load user error: $e");
    }
  }

  Future<void> _saveProfile() async {
    try {
      final body = <String, String>{};
      if (_usernameController.text.isNotEmpty) {
        body["username"] = _usernameController.text.trim();
      }
      if (_emailController.text.isNotEmpty) {
        body["email"] = _emailController.text.trim();
      }

      final res = await http.put(
        Uri.parse("$_baseUrl/user/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200 && data["success"] == true) {
        _snack('Saved!', Colors.green);
      } else {
        _snack(data["error"] ?? "Error", Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      _snack("Server error", Colors.red);
    }
  }

  Future<void> _onTwoFactorToggle(bool value) async {
    if (value) {
      final enabled = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFactorSetupPage(userId: widget.userId),
        ),
      );
      if (enabled == true && mounted) {
        setState(() => _twoFactorEnabled = true);
      }
    } else {
      _showDisable2FADialog();
    }
  }

  void _showDisable2FADialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Disable 2FA"),
        content: const Text(
          "Are you sure you want to disable two-factor authentication? "
              "This will reduce your account security.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _initiateDisable2FA();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Disable"),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateDisable2FA() async {
    setState(() => _twoFactorLoading = true);
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/user/${widget.userId}/2fa/send-disable-code"),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() => _twoFactorLoading = false);

        final disabled = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyActionPage(
              userId: widget.userId,
              title: "Confirm disable 2FA",
              description:
              "Enter the 6-digit code sent to your email to confirm disabling two-factor authentication.",
              onVerified: (code) async {
                final r = await http.post(
                  Uri.parse("$_baseUrl/user/${widget.userId}/2fa/disable"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({"code": code}),
                );
                final d = jsonDecode(r.body);
                return r.statusCode == 200 && d["success"] == true;
              },
            ),
          ),
        );

        if (disabled == true && mounted) {
          setState(() => _twoFactorEnabled = false);
          _snack("Two-factor authentication disabled", Colors.orange);
        }
      } else {
        setState(() => _twoFactorLoading = false);
        _snack(data["error"] ?? "Failed to send code", Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _twoFactorLoading = false);
      _snack("Server error", Colors.red);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete account"),
        content: const Text(
          "Are you sure you want to delete your account? "
              "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "Personal Information",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 36),
                        _buildField(
                          label: "Username",
                          controller: _usernameController,
                          enabled: _usernameEnabled,
                          onEdit: () async {
                            if (_usernameEnabled) await _saveProfile();
                            setState(
                                    () => _usernameEnabled = !_usernameEnabled);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Email",
                          controller: _emailController,
                          enabled: _emailEnabled,
                          keyboardType: TextInputType.emailAddress,
                          onEdit: () async {
                            if (_emailEnabled) await _saveProfile();
                            setState(() => _emailEnabled = !_emailEnabled);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordRow(),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildSecuritySection(),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 32),
                        Center(
                          child: OutlinedButton(
                            onPressed: _showDeleteDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text("Delete account"),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("STEP BY STEP",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _purple)),
              Text("Learn with Flashcards", style: TextStyle(fontSize: 10)),
            ],
          ),
          Icon(Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.black),
                decoration: _baseDecoration,
              ),
            ),
            const SizedBox(width: 12),
            _editBtn(label: enabled ? "Save" : "Edit", onPressed: onEdit),
          ],
        ),
      ],
    );
  }
  Widget _buildPasswordRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                obscureText: true,
                controller: TextEditingController(text: "password"),
                style: const TextStyle(
                    color: Colors.black87, fontSize: 18, letterSpacing: 4),
                decoration: _baseDecoration,
              ),
            ),
            const SizedBox(width: 12),
            _editBtn(
              label: "Edit",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordPage(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Two-factor authentication",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    _twoFactorEnabled
                        ? "Enabled — your account is protected"
                        : "Disabled — we recommend enabling this",
                    style: TextStyle(
                      fontSize: 12,
                      color: _twoFactorEnabled
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _twoFactorLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _purple),
            )
                : Switch(
              value: _twoFactorEnabled,
              activeColor: _purple,
              onChanged: _onTwoFactorToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _editBtn(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 64,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _purple,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
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