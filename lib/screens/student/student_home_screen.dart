import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/token_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/token_card.dart';
import 'token_wallet_screen.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  final UserSession session;

  const StudentHomeScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  int _currentTabIndex = 0;
  late final DateTime _nextMealDate;
  late final bool _isNonVegDay;

  @override
  void initState() {
    super.initState();
    _nextMealDate = MealDateUtils.getNextMealDate();
    _isNonVegDay = MealDateUtils.isNonVegAvailable(_nextMealDate);

    // Refresh manager token counts so availability is up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tokenCountsProvider.notifier).refresh();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from the Token System?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  Future<void> _handlePurchase() async {
    final selection = ref.read(tokenSelectionProvider);
    final success = await ref
        .read(studentActionProvider.notifier)
        .purchaseTokens(widget.session.id, selection);

    if (!mounted) return;

    if (success) {
      AppFeedback.showSnackBar(
        context,
        'Meal tokens booked successfully!',
        isError: false,
      );
      // Switch to wallet tab to show new tokens
      setState(() => _currentTabIndex = 1);
    } else {
      final error = ref.read(studentActionProvider).error;
      if (error != null) {
        AppFeedback.showSnackBar(context, error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(studentActionProvider);
    final selection = ref.watch(tokenSelectionProvider);
    final countsAsync = ref.watch(tokenCountsProvider);
    final studentTokensAsync = ref.watch(studentTokensProvider(widget.session.id));

    return LoadingOverlay(
      isLoading: actionState.isLoading,
      message: 'Processing token purchase...',
      child: AppScaffold(
        title: 'Mess Portal',
        userRole: UserRole.student,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.add_shopping_cart_rounded),
              selectedIcon: Icon(Icons.add_shopping_cart_rounded, color: AppColors.accent),
              label: 'Book Meal',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent),
              label: 'My Tokens',
            ),
          ],
        ),
        body: _currentTabIndex == 1
            ? TokenWalletScreen(rollNumber: widget.session.id)
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Greeting & Roll Number banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hello, ${widget.session.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.session.id,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              'Next Meal: ${MealDateUtils.formatDate(_nextMealDate)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title
                  const Text(
                    'Select Meal Tokens',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose your meal preference for the upcoming dining schedule.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  countsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ),
                    error: (err, _) => Text(
                      'Failed to load token availability: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    data: (counts) {
                      final hasVegAlready =
                          studentTokensAsync.valueOrNull?.veg != null &&
                              studentTokensAsync.valueOrNull!.veg > 0;
                      final hasNonVegAlready =
                          studentTokensAsync.valueOrNull?.nonVeg != null &&
                              studentTokensAsync.valueOrNull!.nonVeg > 0;

                      final vegAvailable = counts.isVegAvailable && !hasVegAlready;
                      final nonVegAvailable =
                          counts.isNonVegAvailable && _isNonVegDay && !hasNonVegAlready;

                      return Column(
                        children: [
                          // Veg Option
                          TokenSelectionCard(
                            title: 'Vegetarian Meal',
                            subtitle: hasVegAlready
                                ? 'Already active in wallet'
                                : 'Available tokens: ${counts.veg}',
                            icon: Icons.eco_rounded,
                            iconColor: AppColors.vegGreen,
                            badgeColor: AppColors.vegGreen,
                            isSelected: selection.wantsVeg,
                            isAvailable: vegAvailable,
                            onToggle: () {
                              if (!vegAvailable) return;
                              ref.read(tokenSelectionProvider.notifier).toggleVeg();
                            },
                          ),

                          // Non-Veg Option
                          TokenSelectionCard(
                            title: 'Non-Vegetarian Meal',
                            subtitle: !_isNonVegDay
                                ? 'Not served on this schedule'
                                : hasNonVegAlready
                                    ? 'Already active in wallet'
                                    : 'Available tokens: ${counts.nonVeg}',
                            icon: Icons.restaurant_rounded,
                            iconColor: AppColors.nonVegRed,
                            badgeColor: AppColors.nonVegRed,
                            isSelected: selection.wantsNonVeg,
                            isAvailable: nonVegAvailable,
                            onToggle: () {
                              if (!nonVegAvailable) return;
                              ref.read(tokenSelectionProvider.notifier).toggleNonVeg();
                            },
                          ),

                          // Eggs Option with Stepper
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selection.eggCount > 0
                                  ? AppColors.surfaceElevated
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selection.eggCount > 0
                                    ? AppColors.eggOrange
                                    : AppColors.cardBorder,
                                width: selection.eggCount > 0 ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.eggOrange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.egg_rounded,
                                      color: AppColors.eggOrange, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Egg Tokens',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add in batches of 15',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: selection.eggCount > 0
                                          ? () => ref
                                              .read(tokenSelectionProvider.notifier)
                                              .decrementEggs()
                                          : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        size: 26,
                                      ),
                                      color: AppColors.eggOrange,
                                    ),
                                    Text(
                                      '${selection.eggCount}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(tokenSelectionProvider.notifier)
                                          .incrementEggs(),
                                      icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 26,
                                      ),
                                      color: AppColors.eggOrange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Confirm & Book Button
                  AppPrimaryButton(
                    label: 'Confirm & Book Tokens',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: selection.hasSelection ? _handlePurchase : null,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
