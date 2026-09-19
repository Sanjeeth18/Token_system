import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../app_text_field.dart';
import '../error_dialog.dart';

/// Modal dialog component for user password updates with validation and error handling.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ChangePasswordDialog(),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();

    setState(() => _isUpdating = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw const FormatException(
          'Authentication session not found. Please log in again.',
        );
      }

      final cred = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPass,
      );

      await currentUser.reauthenticateWithCredential(cred);
      await currentUser.updatePassword(newPass);

      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSnackBar(
          context,
          'Password updated successfully!',
          isError: false,
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to update password. Please try again.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            errorMsg = 'Current password is incorrect.';
            break;
          case 'weak-password':
            errorMsg = 'The new password provided is too weak.';
            break;
          case 'requires-recent-login':
            errorMsg = 'Please sign out and sign in again before changing password.';
            break;
          case 'user-mismatch':
            errorMsg = 'User credential mismatch. Please log in again.';
            break;
          case 'too-many-requests':
            errorMsg = 'Too many attempts. Please try again later.';
            break;
          default:
            errorMsg = e.message ?? e.code;
        }
      } else if (e is FormatException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        setState(() => _isUpdating = false);
        AppFeedback.showSnackBar(context, errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Change Password',
        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: _oldPassController,
                isPassword: true,
                enabled: !_isUpdating,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Current password required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _newPassController,
                isPassword: true,
                enabled: !_isUpdating,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'New password required';
                  if (val.length < 8) return 'Minimum 8 characters required';
                  if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Must contain at least 1 uppercase letter';
                  if (!RegExp(r'[a-z]').hasMatch(val)) return 'Must contain at least 1 lowercase letter';
                  if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(val)) {
                    return 'Must contain at least 1 digit or special character';
                  }
                  if (val == _oldPassController.text.trim()) {
                    return 'New password must differ from current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                controller: _confirmPassController,
                isPassword: true,
                enabled: !_isUpdating,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please confirm your new password';
                  if (val != _newPassController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _handlePasswordUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isUpdating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
