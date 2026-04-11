import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  Shared constants
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  PersonalInformationPage
// ─────────────────────────────────────────────
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
  late TextEditingController _passwordController;

  bool _usernameEnabled = false;
  bool _emailEnabled = false;
  bool _passwordEnabled = false;
  bool _passwordVisible = false;

  bool _twoFactorEnabled = false;
  bool _twoFactorLoading = false;

  static const String _passwordPlaceholder = "••••••••";

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  /// Step 1: POST /user/{id}/send-change-password-code
  /// Step 2: navigate to VerifyActionPage
  /// Step 3: VerifyActionPage calls POST /user/{id}/change-password
  Future<void> _initiatePasswordChange() async {
    final newPassword = _passwordController.text;
    if (newPassword.isEmpty) {
      _snack("Enter a new password", Colors.red);
      return;
    }

    _snack("Sending verification code…", Colors.blueGrey);

    try {
      final res = await http.post(
        Uri.parse(
            "$_baseUrl/user/${widget.userId}/send-change-password-code"),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200 && data["success"] == true) {
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
          _snack("Password changed successfully!", Colors.green);
          setState(() {
            _passwordController.clear();
            _passwordEnabled = false;
            _passwordVisible = false;
          });
        }
      } else {
        _snack(data["error"] ?? "Failed to send code", Colors.red);
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
      if (enabled == true) {
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

  /// Step 1: POST /user/{id}/2fa/send-disable-code
  /// Step 2: navigate to VerifyActionPage
  /// Step 3: VerifyActionPage calls POST /user/{id}/2fa/disable with code
  Future<void> _initiateDisable2FA() async {
    setState(() => _twoFactorLoading = true);
    try {
      final res = await http.post(
        Uri.parse(
            "$_baseUrl/user/${widget.userId}/2fa/send-disable-code"),
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
                  Uri.parse(
                      "$_baseUrl/user/${widget.userId}/2fa/disable"),
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "Personal Information",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 36),
                        _buildField(
                          label: "Username",
                          controller: _usernameController,
                          enabled: _usernameEnabled,
                          onEdit: () async {
                            if (_usernameEnabled) await _saveProfile();
                            setState(() =>
                            _usernameEnabled = !_usernameEnabled);
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
                            setState(
                                    () => _emailEnabled = !_emailEnabled);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text("Learn with Flashcards",
                  style: TextStyle(fontSize: 10)),
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
            _editBtn(
                label: enabled ? "Save" : "Edit", onPressed: onEdit),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
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
              child: _passwordEnabled
              // EDIT MODE
                  ? TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                style: const TextStyle(color: Colors.black),
                decoration: _baseDecoration.copyWith(
                  hintText: "Enter new password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => setState(() =>
                    _passwordVisible = !_passwordVisible),
                  ),
                ),
              )
              // VIEW MODE: dots
                  : TextField(
                enabled: false,
                controller: TextEditingController(
                    text: _passwordPlaceholder),
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    letterSpacing: 4),
                decoration: _baseDecoration,
              ),
            ),
            const SizedBox(width: 12),
            _editBtn(
              label: _passwordEnabled ? "Save" : "Edit",
              onPressed: () async {
                if (_passwordEnabled) {
                  await _initiatePasswordChange();
                } else {
                  _passwordController.clear();
                  setState(() {
                    _passwordEnabled = true;
                    _passwordVisible = false;
                  });
                }
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
            style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            shape: BoxShape.circle,
            color: color.withOpacity(0.8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VerifyActionPage
// ─────────────────────────────────────────────
class VerifyActionPage extends StatefulWidget {
  final int userId;
  final String title;
  final String description;
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
        setState(() =>
        _errorMessage = "Invalid or expired code. Try again.");
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
        title: Text(widget.title,
            style: const TextStyle(
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
                        color: Color(0xFFF0EAFD),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.lock_outline,
                        color: _purple, size: 36),
                  ),
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(widget.description,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.6)),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
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
                  const SizedBox(height: 32),
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
                              strokeWidth: 2,
                              color: Colors.white))
                          : const Text("Confirm",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14)),
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
            shape: BoxShape.circle,
            color: color.withOpacity(0.8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TwoFactorSetupPage
// ─────────────────────────────────────────────
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
        setState(() =>
        _errorMessage = data["error"] ?? "Failed to send code.");
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
      setState(
              () => _errorMessage = "Please enter the 6-digit code.");
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
        _errorMessage =
            data["error"] ?? "Invalid or expired code.");
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
                        color: Color(0xFFF0EAFD),
                        shape: BoxShape.circle),
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
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6),
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
                                color: Colors.green,
                                fontSize: 13)),
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
                        label:
                        const Text("Send code to my email"),
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
                    subtitle:
                    "Type the 6-digit code from your email.",
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
                                        color: Colors.red,
                                        fontSize: 13)),
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
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14)),
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
            shape: BoxShape.circle,
            color: color.withOpacity(0.8)),
      ),
    );
  }
}