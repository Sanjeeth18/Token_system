import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Helper methods for presenting toasts, snackbars, and dialogs.
abstract class AppFeedback {
  /// Sanitizes any raw exception or error object into a clean, professional user message.
  /// Detailed technical details are logged via [debugPrint] for developer debugging.
  static String sanitizeErrorMessage(Object error) {
    debugPrint('[APP_ERROR_LOG]: $error');
    final rawStr = error.toString();
    if (rawStr.contains('user-not-found') ||
        rawStr.contains('wrong-password') ||
        rawStr.contains('invalid-credential')) {
      return 'Invalid username or password. Please try again.';
    }
    if (rawStr.contains('network-request-failed') ||
        rawStr.contains('SocketException')) {
      return 'Network connection issue. Please check your internet connection and try again.';
    }
    if (rawStr.contains('permission-denied') ||
        rawStr.contains('PermissionDenied')) {
      return 'You do not have permission to perform this action.';
    }
    if (rawStr.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    var cleaned = rawStr
        .replaceAll(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'^AppException:\s*'), '')
        .replaceAll(RegExp(r'\[firebase_auth/[^\]]+\]\s*'), '');

    if (cleaned.toLowerCase().contains('database error') ||
        cleaned.toLowerCase().contains('firebase error') ||
        cleaned.toLowerCase().contains('firestore') ||
        cleaned.contains('FormatException')) {
      return 'Unable to complete the operation. Please try again.';
    }

    return cleaned.isNotEmpty
        ? cleaned
        : 'An unexpected error occurred. Please try again.';
  }

  /// Shows a styled SnackBar with icon.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final displayMessage = isError ? sanitizeErrorMessage(message) : message;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows an error alert dialog with custom theme.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog (e.g. for user deletion or logout).
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelLabel,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? AppColors.error : AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
