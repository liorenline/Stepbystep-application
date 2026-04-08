import 'dart:ui';
import 'package:flutter/material.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _firstNameController = TextEditingController(text: 'John');
  final _lastNameController = TextEditingController(text: 'Doe');
  final _emailController = TextEditingController(text: 'johndoe@mail.com');
  final _passwordController = TextEditingController(text: '12345678');

  bool _firstNameEnabled = false;
  bool _lastNameEnabled = false;
  bool _emailEnabled = false;
  bool _passwordEnabled = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Pink blob — top left (blurred)
          Positioned(
            top: -80,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x55F48FB1),
                ),
              ),
            ),
          ),
          // Green blob — bottom right (blurred)
          Positioned(
            bottom: -80,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x55C5E1A5),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Cabinet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildField(
                    label: 'First Name',
                    controller: _firstNameController,
                    enabled: _firstNameEnabled,
                    editLabel: 'Edit',
                    onEdit: () => setState(
                            () => _firstNameEnabled = !_firstNameEnabled),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    enabled: _lastNameEnabled,
                    editLabel: 'Edit',
                    onEdit: () =>
                        setState(() => _lastNameEnabled = !_lastNameEnabled),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    enabled: _emailEnabled,
                    editLabel: 'Edit email',
                    onEdit: () =>
                        setState(() => _emailEnabled = !_emailEnabled),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Password',
                    controller: _passwordController,
                    enabled: _passwordEnabled,
                    editLabel: 'Edit password',
                    onEdit: () =>
                        setState(() => _passwordEnabled = !_passwordEnabled),
                    obscureText: true,
                  ),
                  const SizedBox(height: 36),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton(
                      onPressed: _showDeleteDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: const Text('Delete account'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required String editLabel,
    required VoidCallback onEdit,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 52, // однакова висота для всіх полів
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscureText && !enabled,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7C5CFC)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90, // однакова ширина для всіх кнопок
              child: TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C5CFC),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: Text(
                  enabled ? 'Save' : editLabel,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}