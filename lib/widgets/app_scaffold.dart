import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';

/// Reusable application scaffold providing standard dark gradient background,
/// styled app bar with role badge, and responsive padding.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final UserRole? userRole;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.userRole,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = false,
    this.onBack,
    this.resizeToAvoidBottomInset = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: false,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.textPrimary),
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                    )
                  : null,
              title: Row(
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (userRole != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: userRole == UserRole.admin
                            ? AppColors.adminBadge.withValues(alpha: 0.15)
                            : userRole == UserRole.manager
                                ? AppColors.managerBadge.withValues(alpha: 0.15)
                                : userRole == UserRole.employee
                                    ? AppColors.employeeBadge.withValues(alpha: 0.15)
                                    : AppColors.studentBadge.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: userRole == UserRole.admin
                              ? AppColors.adminBadge.withValues(alpha: 0.4)
                              : userRole == UserRole.manager
                                  ? AppColors.managerBadge.withValues(alpha: 0.4)
                                  : userRole == UserRole.employee
                                      ? AppColors.employeeBadge.withValues(alpha: 0.4)
                                      : AppColors.studentBadge.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        userRole!.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: userRole == UserRole.admin
                              ? AppColors.adminBadge
                              : userRole == UserRole.manager
                                  ? AppColors.managerBadge
                                  : userRole == UserRole.employee
                                      ? AppColors.employeeBadge
                                      : AppColors.studentBadge,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: actions,
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: padding != null
              ? Padding(padding: padding!, child: body)
              : body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
