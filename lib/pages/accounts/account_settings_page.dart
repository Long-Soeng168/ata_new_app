import 'dart:io';
import 'package:ata_new_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountSettingsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AccountSettingsPage({super.key, required this.user});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  void _saveAccountSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.updateUser(
        context: context,
        userId: widget.user['id'],
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        currentPassword: _currentPasswordController.text.isNotEmpty
            ? _currentPasswordController.text
            : null,
        newPassword: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null,
        confirmPassword: _confirmPasswordController.text.isNotEmpty
            ? _confirmPasswordController.text
            : null,
        imageFile: _profileImage,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update failed')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['name'] ?? '';
    _emailController.text = widget.user['email'] ?? '';
    _phoneController.text = widget.user['phone'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDeleteAccountDialog() {
    final _passwordController = TextEditingController();
    String? errorText;
    bool isDeleting = false;
    String? resultMessage;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _handleDeleteAccount() async {
              setState(() {
                isDeleting = true;
                resultMessage = null;
              });

              final result = await _authService.deleteAccount(
                userId: widget.user['id'],
                password: _passwordController.text,
              );

              setState(() {
                isDeleting = false;
                resultMessage = result['message'];
              });

              if (result['success']) {
                // Optionally add a small delay before closing or redirect immediately
                await Future.delayed(const Duration(milliseconds: 500));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            }

            return AlertDialog(
              title: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to delete your account? Please enter your password to confirm. All your data will be permanently removed from our database.",
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (resultMessage != null)
                    Text(
                      resultMessage!,
                      style: TextStyle(
                        color: resultMessage!.toLowerCase().contains('success')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isDeleting
                      ? null
                      : () {
                          if (_passwordController.text.isEmpty) {
                            setState(() {
                              errorText = "Please enter your password.";
                            });
                          } else {
                            setState(() {
                              errorText = null;
                            });
                            _handleDeleteAccount();
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // End Action Delete account

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              size: 32,
              color: Colors.red,
            ),
            onPressed: _showDeleteAccountDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your email" : null,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your phone number" : null,
              ),
              const SizedBox(height: 20),

              // Change Password Section Title
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                decoration:
                    const InputDecoration(labelText: "Current Password"),
                obscureText: true,
              ),
              const SizedBox(height: 12),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
              const SizedBox(height: 12),

              // Confirm New Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: "Confirm New Password"),
                obscureText: true,
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveAccountSettings,
                      child: const Text("Save Changes"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
