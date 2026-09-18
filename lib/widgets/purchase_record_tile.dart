import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/token_model.dart';

/// Reusable tile component for displaying an individual token purchase record.
class PurchaseRecordTile extends StatelessWidget {
  final TokenTransactionModel item;

  const PurchaseRecordTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cat = item.category.toLowerCase();
    final isVeg = cat == 'veg';
    final isNonVeg = cat == 'nonveg' || cat == 'non-veg';

    final color = isVeg
        ? AppColors.vegGreen
        : isNonVeg
            ? AppColors.nonVegRed
            : AppColors.eggOrange;

    final icon = isVeg
        ? Icons.eco_rounded
        : isNonVeg
            ? Icons.restaurant_rounded
            : Icons.egg_rounded;

    final categoryName = isVeg
        ? 'Veg Meal'
        : isNonVeg
            ? 'Non-Veg Meal'
            : 'Egg Token';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          '$categoryName (${item.count})',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Date: ${item.date} • ${item.time}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'PURCHASED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
