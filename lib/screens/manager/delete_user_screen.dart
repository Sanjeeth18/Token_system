import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';

class DeleteUserScreen extends StatefulWidget {
  final UserSession currentUser;

  const DeleteUserScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final _idController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      AppFeedback.showSnackBar(context, 'Please enter a user ID or Roll number', isError: true);
      return;
    }

    // Prohibit deleting admin accounts
    if (id.toLowerCase().startsWith(AppConstants.prefixAdmin.toLowerCase())) {
      AppFeedback.showSnackBar(context, 'Admin accounts cannot be deleted', isError: true);
      return;
    }

    final targetRole = UserRole.fromUsername(id);
    if (targetRole == null) {
      AppFeedback.showSnackBar(context, 'Unrecognized user ID prefix', isError: true);
      return;
    }

    if (!widget.currentUser.role.canManage(targetRole)) {
      AppFeedback.showSnackBar(
        context,
        'You do not have permission to delete ${targetRole.displayName} accounts',
        isError: true,
      );
      return;
    }

    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to permanently delete account "$id"? This action cannot be undone.',
      confirmLabel: 'Delete Forever',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await FirestoreRepository.instance.deleteUser(id, widget.currentUser);
      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        'Account "$id" successfully deleted',
        isError: false,
      );
      Navigator.of(context).pop();
    } on UserNotFoundException {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'User "$id" not found', isError: true);
      }
    } on PermissionDeniedException {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Permission denied', isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Error deleting user: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Deleting user...',
      child: AppScaffold(
        title: 'Delete Account',
        showBackButton: true,
        userRole: widget.currentUser.role,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Warning: Deleting a user permanently removes all account information and token balances.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Account ID / Roll Number',
                      hint: 'e.g. 23XX01, E101',
                      controller: _idController,
                      prefixIcon: Icons.delete_outline_rounded,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppDangerButton(
                label: 'Permanently Delete User',
                icon: Icons.delete_forever_rounded,
                onPressed: _handleDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
