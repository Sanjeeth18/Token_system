import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/token_provider.dart';
import '../../widgets/token_card.dart';
import 'qr_display_screen.dart';

class TokenWalletScreen extends ConsumerWidget {
  final String rollNumber;

  const TokenWalletScreen({
    super.key,
    required this.rollNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(studentTokensProvider(rollNumber));

    return RefreshIndicator(
      onRefresh: () => ref.read(studentTokensProvider(rollNumber).notifier).refresh(rollNumber),
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceElevated,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF162544), Color(0xFF0F1A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.accent, size: 28),
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
                        'Roll: $rollNumber',
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
                  onPressed: () => ref
                      .read(studentTokensProvider(rollNumber).notifier)
                      .refresh(rollNumber),
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
                  // Veg Token
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
                                  rollNumber: rollNumber,
                                  tokenType: TokenType.veg,
                                  availableCount: tokens.veg,
                                ),
                              ),
                            )
                        : null,
                  ),

                  // Non-Veg Token
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
                                  rollNumber: rollNumber,
                                  tokenType: TokenType.nonVeg,
                                  availableCount: tokens.nonVeg,
                                ),
                              ),
                            )
                        : null,
                  ),

                  // Egg Token
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
                                  rollNumber: rollNumber,
                                  tokenType: TokenType.eggs,
                                  availableCount: tokens.eggs,
                                ),
                              ),
                            )
                        : null,
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 20, color: AppColors.textMuted),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Show the QR code at the dining hall scanner to collect your meal.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
