import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/token_model.dart';
import '../../providers/token_provider.dart';
import '../../widgets/category_history_card.dart';
import '../../widgets/purchase_record_tile.dart';
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
  bool _showAllRecords = false;

  Future<void> _navigateToQr(TokenType tokenType, int availableCount) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrDisplayScreen(
          rollNumber: widget.rollNumber,
          tokenType: tokenType,
          availableCount: availableCount,
        ),
      ),
    );
    if (mounted) {
      ref.read(studentTokensProvider(widget.rollNumber).notifier).refresh(widget.rollNumber);
      ref.invalidate(studentPurchasesHistoryProvider(widget.rollNumber));
    }
  }

  void _showCategoryHistory(String categoryTitle, String categoryCode, Color color, List<TokenTransactionModel> history) {
    final filtered = history.where((t) {
      final cat = t.category.toLowerCase();
      if (categoryCode == 'veg') return cat == 'veg';
      if (categoryCode == 'nonveg') return cat == 'nonveg' || cat == 'non-veg';
      if (categoryCode == 'egg') return cat == 'egg' || cat == 'eggs';
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
                          return PurchaseRecordTile(item: filtered[index]);
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
    final historyAsync = ref.watch(studentPurchasesHistoryProvider(widget.rollNumber));
    final history = historyAsync.valueOrNull ?? [];

    final vegCount = history.where((t) => t.category.toLowerCase() == 'veg').length;
    final nonVegCount = history.where((t) {
      final cat = t.category.toLowerCase();
      return cat == 'nonveg' || cat == 'non-veg';
    }).length;
    final eggCount = history.where((t) {
      final cat = t.category.toLowerCase();
      return cat == 'egg' || cat == 'eggs';
    }).length;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(studentTokensProvider(widget.rollNumber).notifier).refresh(widget.rollNumber);
        ref.invalidate(studentPurchasesHistoryProvider(widget.rollNumber));
      },
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceElevated,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Available Meal Tokens Wallet Section
          const Text(
            'Your Meal Tokens',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap any card to open and present your single-use QR pass.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          tokensAsync.when(
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
              child: Text(
                'Error loading wallet tokens: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (tokens) {
              return Column(
                children: [
                  TokenWalletCard(
                    title: 'Veg Meal Token',
                    subtitle: tokens.veg > 0
                        ? 'Valid for Veg Canteen'
                        : 'There are no available tokens',
                    availableCount: tokens.veg,
                    icon: Icons.eco_rounded,
                    color: AppColors.vegGreen,
                    onTap: () => _navigateToQr(TokenType.veg, tokens.veg),
                  ),
                  const SizedBox(height: 12),
                  TokenWalletCard(
                    title: 'Non-Veg Meal Token',
                    subtitle: tokens.nonVeg > 0
                        ? 'Valid for Non-Veg Canteen'
                        : 'There are no available tokens',
                    availableCount: tokens.nonVeg,
                    icon: Icons.restaurant_rounded,
                    color: AppColors.nonVegRed,
                    onTap: () => _navigateToQr(TokenType.nonVeg, tokens.nonVeg),
                  ),
                  const SizedBox(height: 12),
                  TokenWalletCard(
                    title: 'Egg Token',
                    subtitle: tokens.eggs > 0
                        ? 'Valid for Egg counter'
                        : 'There are no available tokens',
                    availableCount: tokens.eggs,
                    icon: Icons.egg_rounded,
                    color: AppColors.eggOrange,
                    onTap: () => _navigateToQr(TokenType.eggs, tokens.eggs),
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

          if (historyAsync.isLoading && history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else
            Column(
              children: [
                CategoryHistoryCard(
                  title: 'Veg Meal History',
                  subtitle: '$vegCount transaction(s) recorded',
                  icon: Icons.eco_rounded,
                  color: AppColors.vegGreen,
                  onTap: () => _showCategoryHistory('Veg Meal', 'veg', AppColors.vegGreen, history),
                ),
                const SizedBox(height: 10),
                CategoryHistoryCard(
                  title: 'Non-Veg Meal History',
                  subtitle: '$nonVegCount transaction(s) recorded',
                  icon: Icons.restaurant_rounded,
                  color: AppColors.nonVegRed,
                  onTap: () => _showCategoryHistory('Non-Veg Meal', 'nonveg', AppColors.nonVegRed, history),
                ),
                const SizedBox(height: 10),
                CategoryHistoryCard(
                  title: 'Eggs History',
                  subtitle: '$eggCount transaction(s) recorded',
                  icon: Icons.egg_rounded,
                  color: AppColors.eggOrange,
                  onTap: () => _showCategoryHistory('Eggs', 'egg', AppColors.eggOrange, history),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Purchased Records',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (history.length > 5)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllRecords = !_showAllRecords;
                            });
                          },
                          child: Text(
                            _showAllRecords ? 'Show Less' : 'Show More',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final displayedHistory =
                          _showAllRecords ? history : history.take(5).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedHistory.length,
                        itemBuilder: (context, index) {
                          return PurchaseRecordTile(item: displayedHistory[index]);
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
