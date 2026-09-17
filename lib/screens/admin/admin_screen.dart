import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/token_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/token_card.dart';
import '../manager/create_user_screen.dart';
import '../manager/delete_user_screen.dart';

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
  final _vegCountController = TextEditingController();
  final _nonVegCountController = TextEditingController();
  bool _isUpdating = false;

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
      message: 'Are you sure you want to sign out from the Admin master console?',
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

    setState(() => _isUpdating = true);
    try {
      await ref.read(tokenCountsProvider.notifier).setCount(type, count);
      controller.clear();
      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        '${type == 'veg' ? 'Veg' : 'Non-Veg'} token pool updated to $count',
        isError: false,
      );
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Failed to update tokens: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(tokenCountsProvider);

    return AppScaffold(
      title: 'Admin Master Console',
      userRole: widget.session.role,
      actions: [
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D1B4E), Color(0xFF161026)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.adminBadge.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.adminBadge.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: AppColors.adminBadge, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.session.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Admin ID: ${widget.session.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

            // Quota Adjustment
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Override Token Pool Quotas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Veg Quota',
                          hint: 'e.g. 150',
                          controller: _vegCountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.eco_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isUpdating
                                ? null
                                : () => _updateCount('veg', _vegCountController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vegGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Set Veg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Non-Veg Quota',
                          hint: 'e.g. 100',
                          controller: _nonVegCountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.restaurant_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isUpdating
                                ? null
                                : () => _updateCount('non-veg', _nonVegCountController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.nonVegRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Set Non-Veg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Elevated User Management
            const Text(
              'Master User Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'As an Admin, you can create and remove Managers, Staff, and Students.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Create Account',
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
                    label: 'Delete Account',
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
