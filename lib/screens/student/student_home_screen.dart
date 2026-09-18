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
import '../profile/profile_screen.dart';

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
    final currentAuth = ref.watch(authProvider);
    final user = currentAuth is AuthAuthenticated ? currentAuth.session : widget.session;

    return LoadingOverlay(
      isLoading: actionState.isLoading,
      message: 'Processing token purchase...',
      child: AppScaffold(
        title: 'Mess Portal',
        userRole: UserRole.student,
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
                  // Hero Profile Banner Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  child: Text(
                                    widget.session.name.isNotEmpty
                                        ? widget.session.name[0].toUpperCase()
                                        : 'S',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${widget.session.name}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Student Portal',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                widget.session.id,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_available_rounded,
                                  size: 16, color: AppColors.studentBadge),
                              const SizedBox(width: 8),
                              Text(
                                'Next Dining Session: ${MealDateUtils.formatDate(_nextMealDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Card
                  InkWell(
                    onTap: () => setState(() => _currentTabIndex = 1),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.vegGreen.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.vegGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.vegGreen, size: 26),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Active Tokens',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Show active pass QR to redeem meal',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title
                  const Text(
                    'Meal Booking Menu',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select your meal choices for the upcoming hostel dining session.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  countsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ),
                    error: (err, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Failed to load token availability: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    data: (counts) {
                      final studentVeg =
                          studentTokensAsync.valueOrNull?.veg ?? 0;
                      final studentNonVeg =
                          studentTokensAsync.valueOrNull?.nonVeg ?? 0;

                      // Veg Validation:
                      // 1. studentTokens.veg > 0 => "Veg token already purchased."
                      // 2. counts.veg <= 0 => "Veg tokens are sold out."
                      final String? vegUnavailableReason = studentVeg > 0
                          ? 'Veg token already purchased.'
                          : (counts.veg <= 0 ? 'Veg tokens are sold out.' : null);

                      final isVegAvailable = vegUnavailableReason == null;
                      final vegSubtext = vegUnavailableReason ?? 'Available';

                      // Non-Veg Validation:
                      // 1. Not scheduled Non-Veg day => "Non-Veg meal is not served on this dining schedule."
                      // 2. studentTokens.nonVeg > 0 => "Non-Veg token already purchased."
                      // 3. counts.nonVeg <= 0 => "Non-Veg tokens are sold out."
                      final String? nonVegUnavailableReason = !_isNonVegDay
                          ? 'Non-Veg meal is not served on this dining schedule.'
                          : (studentNonVeg > 0
                              ? 'Non-Veg token already purchased.'
                              : (counts.nonVeg <= 0 ? 'Non-Veg tokens are sold out.' : null));

                      final isNonVegAvailable = nonVegUnavailableReason == null;
                      final nonVegSubtext = nonVegUnavailableReason ?? 'Available';

                      return Column(
                        children: [
                          // Veg Option
                          TokenSelectionCard(
                            title: 'Veg Meal',
                            subtitle: vegSubtext,
                            icon: Icons.eco_rounded,
                            iconColor: AppColors.vegGreen,
                            badgeColor: AppColors.vegGreen,
                            isSelected: selection.wantsVeg,
                            isAvailable: isVegAvailable,
                            onToggle: () {
                              if (!isVegAvailable) return;
                              ref.read(tokenSelectionProvider.notifier).toggleVeg();
                            },
                          ),

                          // Non-Veg Option
                          TokenSelectionCard(
                            title: 'Non-Veg Meal',
                            subtitle: nonVegSubtext,
                            icon: Icons.restaurant_rounded,
                            iconColor: AppColors.nonVegRed,
                            badgeColor: AppColors.nonVegRed,
                            isSelected: selection.wantsNonVeg,
                            isAvailable: isNonVegAvailable,
                            onToggle: () {
                              if (!isNonVegAvailable) return;
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
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selection.eggCount > 0
                                    ? AppColors.eggYellow
                                    : AppColors.cardBorder,
                                width: selection.eggCount > 0 ? 1.8 : 1,
                              ),
                              boxShadow: selection.eggCount > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.eggYellow.withValues(alpha: 0.25),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.eggYellow.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.eggYellow.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(Icons.egg_rounded,
                                      color: AppColors.eggYellow, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Egg Tokens',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add in batches of 15 eggs',
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
                                      color: AppColors.eggYellow,
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
                                      color: AppColors.eggYellow,
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

                  const SizedBox(height: 28),

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
