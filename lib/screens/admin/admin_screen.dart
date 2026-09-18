import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/token_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/profile_header_banner.dart';
import '../../widgets/token_card.dart';
import '../manager/create_user_screen.dart';
import '../manager/delete_user_screen.dart';
import '../profile/profile_screen.dart';
import 'view_members_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  final UserSession session;

  const AdminScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenCountsProvider.notifier).refresh();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Sign Out',
      message:
          'Are you sure you want to sign out from the Admin master console?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(tokenCountsProvider);
    final currentAuth = ref.watch(authProvider);
    final user =
        currentAuth is AuthAuthenticated ? currentAuth.session : widget.session;

    return AppScaffold(
      title: 'Admin Console',
      userRole: user.role,
      actions: [
        IconButton(
          icon: const Icon(Icons.people_rounded, color: AppColors.accentLight),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewMembersScreen(currentUser: user),
              ),
            );
          },
          tooltip: 'View Members',
        ),
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
          icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
          onPressed: () => ref.read(tokenCountsProvider.notifier).refresh(),
          tooltip: 'Refresh Stats',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
          tooltip: 'Sign Out',
          onPressed: _handleLogout,
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.read(tokenCountsProvider.notifier).refresh(),
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceElevated,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Admin Profile Banner
            ProfileHeaderBanner(
              session: user,
              trailingBadge: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.adminBadge.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SUPERUSER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adminBadge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Token Metrics Grid
            const Text(
              'System-Wide Token Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            countsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error loading counts: $err',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (counts) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    TokenStatCard(
                      title: 'Veg Available',
                      value: '${counts.veg}',
                      icon: Icons.eco_rounded,
                      color: AppColors.vegGreen,
                      subtitle: '${counts.vegPurchased} booked today',
                    ),
                    TokenStatCard(
                      title: 'Non-Veg Available',
                      value: '${counts.nonVeg}',
                      icon: Icons.restaurant_rounded,
                      color: AppColors.nonVegRed,
                      subtitle: '${counts.nonVegPurchased} booked today',
                    ),
                    TokenStatCard(
                      title: 'Veg Booked',
                      value: '${counts.vegPurchased}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.accentLight,
                    ),
                    TokenStatCard(
                      title: 'Non-Veg Booked',
                      value: '${counts.nonVegPurchased}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.eggOrange,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Elevated User Management
            const Text(
              'Manage System Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppOutlineButton(
                      label: 'Create',
                      icon: Icons.person_add_rounded,
                      color: AppColors.accentLight,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateUserScreen(currentUser: widget.session),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppOutlineButton(
                      label: 'Delete',
                      icon: Icons.person_remove_rounded,
                      color: AppColors.error,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DeleteUserScreen(currentUser: widget.session),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
