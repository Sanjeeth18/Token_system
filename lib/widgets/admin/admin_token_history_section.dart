import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/token_model.dart';
import '../../providers/token_provider.dart';

/// Section component displaying token history logs and analytics in the Admin Console.
class AdminTokenHistorySection extends ConsumerStatefulWidget {
  const AdminTokenHistorySection({super.key});

  @override
  ConsumerState<AdminTokenHistorySection> createState() =>
      _AdminTokenHistorySectionState();
}

class _AdminTokenHistorySectionState
    extends ConsumerState<AdminTokenHistorySection> {
  String _selectedCategory = 'veg'; // 'veg', 'nonveg', 'egg'
  int _selectedLogType = 0; // 0 = Purchased Log, 1 = Used/Redeemed Log

  @override
  Widget build(BuildContext context) {
    final purchasesAsync =
        ref.watch(purchasesHistoryProvider(_selectedCategory));
    final redemptionsAsync =
        ref.watch(redemptionsHistoryProvider(_selectedCategory));
    final eggSummaryAsync = ref.watch(eggTokenSummaryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_toggle_off_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Token History & Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    size: 20, color: AppColors.accent),
                onPressed: () {
                  ref.invalidate(purchasesHistoryProvider);
                  ref.invalidate(redemptionsHistoryProvider);
                  ref.invalidate(eggTokenSummaryProvider);
                },
                tooltip: 'Refresh History',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Chips
          Row(
            children: [
              _buildCategoryChip(
                  'veg', 'Veg', Icons.eco_rounded, AppColors.vegGreen),
              const SizedBox(width: 8),
              _buildCategoryChip('nonveg', 'Non-Veg', Icons.restaurant_rounded,
                  AppColors.nonVegRed),
              const SizedBox(width: 8),
              _buildCategoryChip(
                  'egg', 'Eggs', Icons.egg_rounded, AppColors.eggYellow),
            ],
          ),
          const SizedBox(height: 16),

          // Egg Summary Metric Card (shown when category == 'egg')
          if (_selectedCategory == 'egg') ...[
            eggSummaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.eggYellow, strokeWidth: 2)),
              ),
              error: (err, _) => Text('Error loading summary: $err',
                  style: const TextStyle(color: AppColors.error)),
              data: (summary) => Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.eggYellow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.eggYellow.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Egg Token Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eggYellow,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEggMetricItem('Purchased', '${summary.purchased}',
                            AppColors.accentLight),
                        Container(
                            height: 30, width: 1, color: AppColors.cardBorder),
                        _buildEggMetricItem('Used (Redeemed)',
                            '${summary.used}', AppColors.vegGreen),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Log Type Selector: Purchased vs Redeemed
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
                        'Purchased Log',
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
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Used / Redeemed Log',
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

          // Log List
          if (_selectedLogType == 0)
            _buildLogList(purchasesAsync, 'purchased')
          else
            _buildLogList(redemptionsAsync, 'redeemed'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String key, String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = key),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.cardBorder,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: isSelected ? color : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEggMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLogList(
      AsyncValue<List<TokenTransactionModel>> asyncVal, String typeLabel) {
    return asyncVal.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 2)),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Failed to load records: $err',
            style: const TextStyle(color: AppColors.error)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text(
              'No $typeLabel records found.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length > 20 ? 20 : items.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppColors.cardBorder, height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Icon(
                    typeLabel == 'purchased'
                        ? Icons.add_shopping_cart_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${item.rollNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.date} at ${item.time}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.count} ${item.category.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentLight,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
