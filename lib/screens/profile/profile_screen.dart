import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final UserSession session;

  const ProfileScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAuth = ref.watch(authProvider);
    final user = currentAuth is AuthAuthenticated ? currentAuth.session : session;
    final Color roleColor = _getRoleColor(user.role);

    return AppScaffold(
      title: 'User Profile',
      showBackButton: true,
      userRole: user.role,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
          color: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (val) {
            if (val == 'create') {
              Navigator.pushNamed(context, AppConstants.routeCreateUser, arguments: user);
            } else if (val == 'delete') {
              Navigator.pushNamed(context, AppConstants.routeDeleteUser, arguments: user);
            } else if (val == 'change_password') {
              _showChangePasswordDialog(context, user);
            } else if (val == 'forgot_password') {
              _handleForgotPassword(context, user);
            }
          },
          itemBuilder: (context) => [
            if (user.role == UserRole.manager) ...[
              const PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.person_add_outlined, size: 20, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Create Account', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: 20, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Delete Account', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
            ],
            const PopupMenuItem(
              value: 'change_password',
              child: Row(
                children: [
                  Icon(Icons.lock_reset_rounded, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 10),
                  Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'forgot_password',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_rounded, size: 20, color: AppColors.textPrimary),
                  SizedBox(width: 10),
                  Text('Forgot Password', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cover & Profile Avatar Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gradient Cover Banner
                  Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                  // Overlapping Avatar & Info
                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: roleColor,
                              width: 3.5,
                            ),
                            color: AppColors.surfaceElevated,
                            boxShadow: [
                              BoxShadow(
                                color: roleColor.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                ? Image.network(
                                    user.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarFallback(user, roleColor),
                                  )
                                : _buildAvatarFallback(user, roleColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            user.role.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileTile(
                    icon: Icons.badge_outlined,
                    label: user.role.idLabel,
                    value: user.id,
                    iconColor: roleColor,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  _buildProfileTile(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: user.email ?? '${user.id.toLowerCase()}@psgtoken.com',
                    iconColor: AppColors.accentLight,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  _buildProfileTile(
                    icon: Icons.school_outlined,
                    label: user.role == UserRole.student ? 'Course' : 'Department',
                    value: user.department ?? 'General',
                    iconColor: AppColors.eggYellow,
                  ),
                  if (user.doj != null) ...[
                    const Divider(color: AppColors.cardBorder, height: 24),
                    _buildProfileTile(
                      icon: Icons.calendar_month_outlined,
                      label: 'Date of Joining',
                      value: user.doj!,
                      iconColor: AppColors.vegGreen,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Center Section
            AppPrimaryButton(
              label: 'Edit Profile',
              icon: Icons.edit_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(session: user),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    label: 'Change Password',
                    icon: Icons.lock_reset_rounded,
                    color: AppColors.accentLight,
                    onPressed: () => _showChangePasswordDialog(context, user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppOutlineButton(
                    label: 'Forgot Password',
                    icon: Icons.mark_email_read_rounded,
                    color: AppColors.eggYellow,
                    onPressed: () => _handleForgotPassword(context, user),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    return switch (role) {
      UserRole.admin => AppColors.adminBadge,
      UserRole.manager => AppColors.managerBadge,
      UserRole.employee => AppColors.employeeBadge,
      UserRole.student => AppColors.studentBadge,
    };
  }

  Future<void> _handleForgotPassword(BuildContext context, UserSession user) async {
    final targetEmail = user.email ?? '${user.id.toLowerCase()}@psgtoken.com';
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: targetEmail);
      if (context.mounted) {
        AppFeedback.showSnackBar(
          context,
          'Password reset email sent to $targetEmail',
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showSnackBar(
          context,
          'Failed to send reset email: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context, UserSession user) async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Change Password',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        label: 'Current Password',
                        hint: 'Enter current password',
                        controller: oldPassController,
                        isPassword: true,
                        enabled: !isUpdating,
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
                        controller: newPassController,
                        isPassword: true,
                        enabled: !isUpdating,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'New password required';
                          if (val.length < 8) return 'Minimum 8 characters required';
                          if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Must contain at least 1 uppercase letter';
                          if (!RegExp(r'[a-z]').hasMatch(val)) return 'Must contain at least 1 lowercase letter';
                          if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(val)) {
                            return 'Must contain at least 1 digit or special character';
                          }
                          if (val == oldPassController.text.trim()) {
                            return 'New password must differ from current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: 'Re-enter new password',
                        controller: confirmPassController,
                        isPassword: true,
                        enabled: !isUpdating,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please confirm your new password';
                          if (val != newPassController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final oldPass = oldPassController.text.trim();
                          final newPass = newPassController.text.trim();

                          setDialogState(() => isUpdating = true);

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

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
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

                            if (ctx.mounted) {
                              setDialogState(() => isUpdating = false);
                              AppFeedback.showSnackBar(ctx, errorMsg, isError: true);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isUpdating
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
          },
        );
      },
    );

    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
  }

  Widget _buildAvatarFallback(UserSession user, Color roleColor) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: roleColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

