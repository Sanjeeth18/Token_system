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
import '../../widgets/token_quota_card.dart';
import 'create_user_screen.dart';
import 'delete_user_screen.dart';
import '../profile/profile_screen.dart';

class ManagerScreen extends ConsumerStatefulWidget {
  final UserSession session;

  const ManagerScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends ConsumerState<ManagerScreen> {
  final _vegCountController = TextEditingController();
  final _nonVegCountController = TextEditingController();
  bool _isUpdatingVeg = false;
  bool _isUpdatingNonVeg = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenCountsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _vegCountController.dispose();
    _nonVegCountController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from the Manager console?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  Future<void> _updateCount(String type, TextEditingController controller) async {
    final count = int.tryParse(controller.text.trim());
    if (count == null || count < 0) {
      AppFeedback.showSnackBar(context, 'Please enter a valid non-negative number', isError: true);
      return;
    }

    final isVeg = type == 'veg';
    setState(() {
      if (isVeg) {
        _isUpdatingVeg = true;
      } else {
        _isUpdatingNonVeg = true;
      }
    });

    try {
      await ref.read(tokenCountsProvider.notifier).setCount(type, count);
      controller.clear();
      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        '${isVeg ? 'Veg' : 'Non-Veg'} token pool updated to $count',
        isError: false,
      );
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Failed to update tokens: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isVeg) {
            _isUpdatingVeg = false;
          } else {
            _isUpdatingNonVeg = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(tokenCountsProvider);
    final currentAuth = ref.watch(authProvider);
    final user = currentAuth is AuthAuthenticated ? currentAuth.session : widget.session;

    return AppScaffold(
      title: 'Manager Console',
      userRole: user.role,
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
            // Manager Profile Banner
            ProfileHeaderBanner(session: user),
            const SizedBox(height: 24),

            // Token Metrics Grid
            const Text(
              'Live Meal Token Stats',
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

            // Daily Quota Controls Card Component
            TokenQuotaCard(
              vegController: _vegCountController,
              nonVegController: _nonVegCountController,
              isUpdatingVeg: _isUpdatingVeg,
              isUpdatingNonVeg: _isUpdatingNonVeg,
              onUpdateVeg: () => _updateCount('veg', _vegCountController),
              onUpdateNonVeg: () => _updateCount('non-veg', _nonVegCountController),
            ),
            const SizedBox(height: 28),

            // User Management Actions
            const Text(
              'Account Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Add User',
                    icon: Icons.person_add_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateUserScreen(currentUser: widget.session),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppOutlineButton(
                    label: 'Delete User',
                    icon: Icons.person_remove_rounded,
                    color: AppColors.error,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeleteUserScreen(currentUser: widget.session),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
