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
  int _selectedLogType = 0; // 0 = Purchased Log, 1 = Used / Redeemed Log

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
      ref.invalidate(studentRedemptionsHistoryProvider(widget.rollNumber));
    }
  }

  void _showCategoryHistory({
    required String categoryTitle,
    required String categoryCode,
    required Color color,
    required List<TokenTransactionModel> history,
    required bool isRedemption,
  }) {
    final filtered = history.where((t) {
      final cat = t.category.toLowerCase();
      if (categoryCode == 'veg') return cat == 'veg';
      if (categoryCode == 'nonveg') return cat == 'nonveg' || cat == 'non-veg';
      if (categoryCode == 'egg') return cat == 'egg' || cat == 'eggs';
      return false;
    }).toList();

    final typeLabel = isRedemption ? 'Usage / Redemption' : 'Purchase';

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '$categoryTitle $typeLabel History',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
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
                          'No $categoryTitle ${typeLabel.toLowerCase()} records found.',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return PurchaseRecordTile(
                            item: filtered[index],
                            isRedemption: isRedemption,
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
    final purchasesAsync = ref.watch(studentPurchasesHistoryProvider(widget.rollNumber));
    final redemptionsAsync = ref.watch(studentRedemptionsHistoryProvider(widget.rollNumber));

    final isRedemptionLog = _selectedLogType == 1;
    final historyAsync = isRedemptionLog ? redemptionsAsync : purchasesAsync;
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
        ref.invalidate(studentRedemptionsHistoryProvider(widget.rollNumber));
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
                    count: tokens.veg,
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
                    count: tokens.nonVeg,
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
                    count: tokens.eggs,
                    icon: Icons.egg_rounded,
                    color: AppColors.eggOrange,
                    onTap: () => _navigateToQr(TokenType.eggs, tokens.eggs),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Transaction History Header & Log Switcher
          const Text(
            'Token Activity & Transaction History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Switch between Purchased tokens and Used/Redeemed token transactions.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Log Type Segmented Switcher
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedLogType = 0),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedLogType == 0
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Purchased History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedLogType == 0
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedLogType = 1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedLogType == 1
                            ? AppColors.accentLight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Used / Redeemed History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedLogType == 1
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                  subtitle: '$vegCount ${isRedemptionLog ? 'used' : 'purchased'} transaction(s)',
                  icon: Icons.eco_rounded,
                  color: AppColors.vegGreen,
                  onTap: () => _showCategoryHistory(
                    categoryTitle: 'Veg Meal',
                    categoryCode: 'veg',
                    color: AppColors.vegGreen,
                    history: history,
                    isRedemption: isRedemptionLog,
                  ),
                ),
                const SizedBox(height: 10),
                CategoryHistoryCard(
                  title: 'Non-Veg Meal History',
                  subtitle: '$nonVegCount ${isRedemptionLog ? 'used' : 'purchased'} transaction(s)',
                  icon: Icons.restaurant_rounded,
                  color: AppColors.nonVegRed,
                  onTap: () => _showCategoryHistory(
                    categoryTitle: 'Non-Veg Meal',
                    categoryCode: 'nonveg',
                    color: AppColors.nonVegRed,
                    history: history,
                    isRedemption: isRedemptionLog,
                  ),
                ),
                const SizedBox(height: 10),
                CategoryHistoryCard(
                  title: 'Eggs History',
                  subtitle: '$eggCount ${isRedemptionLog ? 'used' : 'purchased'} transaction(s)',
                  icon: Icons.egg_rounded,
                  color: AppColors.eggOrange,
                  onTap: () => _showCategoryHistory(
                    categoryTitle: 'Eggs',
                    categoryCode: 'egg',
                    color: AppColors.eggOrange,
                    history: history,
                    isRedemption: isRedemptionLog,
                  ),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRedemptionLog ? 'All Used / Redeemed Records' : 'All Purchased Records',
                        style: const TextStyle(
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
                          return PurchaseRecordTile(
                            item: displayedHistory[index],
                            isRedemption: isRedemptionLog,
                          );
                        },
                      );
                    },
                  ),
                ],
                if (history.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        isRedemptionLog
                            ? 'No used/redeemed token records found yet.'
                            : 'No purchased token records found yet.',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
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
