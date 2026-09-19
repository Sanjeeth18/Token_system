import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_dialog.dart';
import 'scanner_screen.dart';
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
  Widget build(BuildContext context) {
    final currentAuth = ref.watch(authProvider);
    final user =
        currentAuth is AuthAuthenticated ? currentAuth.session : widget.session;

    return AppScaffold(
      title: 'Staff Terminal',
      actions: [
        if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(session: user),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                  image: DecorationImage(
                    image: NetworkImage(user.photoUrl!.trim()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        else
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
                    if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty)
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.employeeBadge,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.employeeBadge.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(user.photoUrl!.trim()),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
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
                          Icons.badge_rounded,
                          color: AppColors.employeeBadge,
                          size: 40,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Staff ID: ${user.id}',
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

              // Scan Counter QR Action Section
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScannerScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.accentLight,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan QR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Scan student token QR to validate and redeem meal passes at the counter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScannerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        label: const Text('Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
