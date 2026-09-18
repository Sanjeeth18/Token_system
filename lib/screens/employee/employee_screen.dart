import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_dialog.dart';

import '../profile/profile_screen.dart';

class EmployeeScreen extends ConsumerStatefulWidget {
  final UserSession session;

  const EmployeeScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends ConsumerState<EmployeeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from the Scanner terminal?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAuth = ref.watch(authProvider);
    final user =
        currentAuth is AuthAuthenticated ? currentAuth.session : widget.session;

    return AppScaffold(
      title: 'Staff Terminal',
      userRole: UserRole.employee,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_rounded, color: AppColors.accent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(session: user),
              ),
            );
          },
          tooltip: 'Profile',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
          tooltip: 'Sign Out',
          onPressed: () => _handleLogout(context, ref),
        ),
      ],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Staff Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.employeeBadge.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.employeeBadge.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.employeeBadge.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                AppColors.employeeBadge.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.employeeBadge,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.session.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Staff ID: ${widget.session.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // QR Codes Display Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'QR Codes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Students scan these QR codes on their device to purchase meal tokens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        children: [
                          // Veg QR Code
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: AppColors.vegGreen
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'VEG TOKEN',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.vegGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: QrImageView(
                                      data: 'PURCHASE_VEG_TOKEN',
                                      version: QrVersions.auto,
                                      size: 150,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Non-Veg QR Code
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: AppColors.nonVegRed
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'NON-VEG TOKEN',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.nonVegRed,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: QrImageView(
                                      data: 'PURCHASE_NONVEG_TOKEN',
                                      version: QrVersions.auto,
                                      size: 150,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        2,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.accent
                                : AppColors.textMuted.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
