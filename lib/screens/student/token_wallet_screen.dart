import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/token_model.dart';
import '../../providers/token_provider.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/token_card.dart';
import 'qr_display_screen.dart';

class TokenWalletScreen extends ConsumerStatefulWidget {
  final String rollNumber;

  const TokenWalletScreen({
    super.key,
    required this.rollNumber,
  });

  @override
  ConsumerState<TokenWalletScreen> createState() => _TokenWalletScreenState();
}

class _TokenWalletScreenState extends ConsumerState<TokenWalletScreen> {
  bool _isLoadingHistory = true;
  List<TokenTransactionModel> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final list = await FirestoreRepository.instance
          .getStudentTransactionHistory(widget.rollNumber);
      if (mounted) {
        setState(() {
          _history = list;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  void _showCategoryHistory(String categoryTitle, String categoryCode, Color color) {
    final filtered = _history.where((t) {
      if (categoryCode == 'veg') return t.category == 'veg';
      if (categoryCode == 'nonveg') return t.category == 'nonveg' || t.category == 'non-veg';
      if (categoryCode == 'egg') return t.category == 'egg' || t.category == 'eggs';
      return false;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$categoryTitle History',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 8),
              filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'No $categoryTitle purchase history found.',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.cardBorder),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Icon(
                                  categoryCode == 'veg'
                                      ? Icons.eco_rounded
                                      : categoryCode == 'nonveg'
                                          ? Icons.restaurant_rounded
                                          : Icons.egg_rounded,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                '${item.count} Token(s) Purchased',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${item.date} at ${item.time}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.vegGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'RECORDED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.vegGreen,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokensAsync = ref.watch(studentTokensProvider(widget.rollNumber));

    final vegCount = _history.where((t) => t.category == 'veg').length;
    final nonVegCount = _history.where((t) => t.category == 'nonveg' || t.category == 'non-veg').length;
    final eggCount = _history.where((t) => t.category == 'egg' || t.category == 'eggs').length;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(studentTokensProvider(widget.rollNumber).notifier).refresh(widget.rollNumber);
        await _fetchHistory();
      },
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceElevated,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.accentLight, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Tokens',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll Number: ${widget.rollNumber}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
                  onPressed: () {
                    ref.read(studentTokensProvider(widget.rollNumber).notifier).refresh(widget.rollNumber);
                    _fetchHistory();
                  },
                  tooltip: 'Refresh Tokens',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          tokensAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Error loading tokens: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (tokens) {
              return Column(
                children: [
                  TokenWalletCard(
                    title: 'Vegetarian Meal Token',
                    count: tokens.veg,
                    icon: Icons.eco_rounded,
                    color: AppColors.vegGreen,
                    onShowQr: tokens.veg > 0
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QrDisplayScreen(
                                  rollNumber: widget.rollNumber,
                                  tokenType: TokenType.veg,
                                  availableCount: tokens.veg,
                                ),
                              ),
                            )
                        : null,
                  ),
                  TokenWalletCard(
                    title: 'Non-Vegetarian Meal Token',
                    count: tokens.nonVeg,
                    icon: Icons.restaurant_rounded,
                    color: AppColors.nonVegRed,
                    onShowQr: tokens.nonVeg > 0
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QrDisplayScreen(
                                  rollNumber: widget.rollNumber,
                                  tokenType: TokenType.nonVeg,
                                  availableCount: tokens.nonVeg,
                                ),
                              ),
                            )
                        : null,
                  ),
                  TokenWalletCard(
                    title: 'Egg Tokens',
                    count: tokens.eggs,
                    icon: Icons.egg_rounded,
                    color: AppColors.eggOrange,
                    onShowQr: tokens.eggs > 0
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QrDisplayScreen(
                                  rollNumber: widget.rollNumber,
                                  tokenType: TokenType.eggs,
                                  availableCount: tokens.eggs,
                                ),
                              ),
                            )
                        : null,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Categorized Purchase History Section
          const Text(
            'Purchase History by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a category to view detailed transactions with date & time.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          if (_isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else
            Column(
              children: [
                _buildCategoryHistoryCard(
                  title: 'Veg Meal History',
                  subtitle: '$vegCount transaction(s) recorded',
                  icon: Icons.eco_rounded,
                  color: AppColors.vegGreen,
                  onTap: () => _showCategoryHistory('Veg Meal', 'veg', AppColors.vegGreen),
                ),
                const SizedBox(height: 10),
                _buildCategoryHistoryCard(
                  title: 'Non-Veg Meal History',
                  subtitle: '$nonVegCount transaction(s) recorded',
                  icon: Icons.restaurant_rounded,
                  color: AppColors.nonVegRed,
                  onTap: () => _showCategoryHistory('Non-Veg Meal', 'nonveg', AppColors.nonVegRed),
                ),
                const SizedBox(height: 10),
                _buildCategoryHistoryCard(
                  title: 'Eggs History',
                  subtitle: '$eggCount transaction(s) recorded',
                  icon: Icons.egg_rounded,
                  color: AppColors.eggOrange,
                  onTap: () => _showCategoryHistory('Eggs', 'egg', AppColors.eggOrange),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryHistoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: AppColors.textMuted),
      ),
    );
  }
}
