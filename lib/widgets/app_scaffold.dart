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
                  Flexible(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
