import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_utils.dart';
import 'app_text_field.dart';

/// Reusable card component for managing daily token pool quotas.
class TokenQuotaCard extends StatelessWidget {
  final TextEditingController vegController;
  final TextEditingController nonVegController;
  final bool isUpdatingVeg;
  final bool isUpdatingNonVeg;
  final VoidCallback onUpdateVeg;
  final VoidCallback onUpdateNonVeg;

  const TokenQuotaCard({
    super.key,
    required this.vegController,
    required this.nonVegController,
    required this.isUpdatingVeg,
    required this.isUpdatingNonVeg,
    required this.onUpdateVeg,
    required this.onUpdateNonVeg,
  });

  @override
  Widget build(BuildContext context) {
    final canUpdateVeg = MealDateUtils.canManagerUpdateVeg();
    final canUpdateNonVeg = MealDateUtils.canManagerUpdateNonVeg();

    return Container(
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
            'Set Token Pool Quota',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Token pool updates are allowed only before 6:00 AM.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),

          if (!canUpdateVeg && !canUpdateNonVeg) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.eggOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.eggOrange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.eggOrange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quota updates closed for today. Manager updates are allowed only before 6:00 AM.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Veg Quota Row (only displayed before 6:00 AM)
            if (canUpdateVeg) ...[
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Veg Quota',
                      hint: 'e.g. 5000',
                      controller: vegController,
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
                        onPressed: isUpdatingVeg ? null : onUpdateVeg,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vegGreen,
                          disabledBackgroundColor:
                              AppColors.vegGreen.withValues(alpha: 0.8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUpdatingVeg
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Set Veg'),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (canUpdateVeg && canUpdateNonVeg) const SizedBox(height: 16),

            // Non-Veg Quota Row (only displayed before 6:00 AM)
            if (canUpdateNonVeg) ...[
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Non-Veg Quota',
                      hint: 'e.g. 1000',
                      controller: nonVegController,
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
                        onPressed: isUpdatingNonVeg ? null : onUpdateNonVeg,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.nonVegRed,
                          disabledBackgroundColor:
                              AppColors.nonVegRed.withValues(alpha: 0.8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUpdatingNonVeg
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Set Non-Veg'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
